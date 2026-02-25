using System;
using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class PlayerShootingState : PlayerBaseState
{
    private readonly int ShootAnim = Animator.StringToHash("Shoot");
    private const float CrossFadeDuration = 0.1f;
    float speed = 100f;
    public PlayerShootingState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    private float _nextFireTime;
    private Vector3 _currentHitPoint;
    private bool _hasHitTarget;

    private float _rotationX;
    private float _rotationY;

    public override void Enter()
    {
        // CAMERA IN
        stateMachine.aimCamera.Priority = 10;
        stateMachine.Animator.CrossFadeInFixedTime(ShootAnim, CrossFadeDuration);

        if (stateMachine.ReticleTransform != null)
            stateMachine.ReticleTransform.gameObject.SetActive(true);

        _rotationX = stateMachine.transform.eulerAngles.y;
        _rotationY = 0f;
    }

    public override void Tick(float deltaTime)
    {
        if (!stateMachine.InputReader.isAiming) 
        {
            stateMachine.ReturnToMainState();
            return;
        }
        
        HandleLookRotation(deltaTime);
        
        UpdateReticlePosition();
        
        HandleAimMovement(deltaTime);

        
        if (stateMachine.InputReader.IsFiring && Time.time >= _nextFireTime)
        {
            Shoot();
            _nextFireTime = Time.time + stateMachine.FireCooldown;
        }
    }

    public override void Exit()
    {
        stateMachine.aimCamera.Priority = -1;
        
        if (stateMachine.ReticleTransform != null)
            stateMachine.ReticleTransform.gameObject.SetActive(false);
    }

    private void UpdateReticlePosition()
    {
        if (stateMachine.ReticleTransform == null) return;

        Ray ray = Camera.main.ViewportPointToRay(new Vector3(0.5f, 0.5f, 0f)); // Centro pantalla

        
        bool hit = Physics.Raycast(ray, out RaycastHit hitInfo, stateMachine.MaxAimDistance, stateMachine.AimLayerMask);

        if (hit)
        {
            _hasHitTarget = true;
            _currentHitPoint = hitInfo.point;

            
            stateMachine.ReticleTransform.position = hitInfo.point + hitInfo.normal * stateMachine.ReticleSurfaceOffset;

            stateMachine.ReticleTransform.gameObject.SetActive(true);

            stateMachine.ReticleTransform.rotation = Quaternion.LookRotation(hitInfo.normal);
        }
        else
        {
            _hasHitTarget = false;
            
            _currentHitPoint = ray.GetPoint(stateMachine.MaxAimDistance);

            
            stateMachine.ReticleTransform.gameObject.SetActive(false);

            
            stateMachine.ReticleTransform.position = _currentHitPoint;
            stateMachine.ReticleTransform.rotation = Quaternion.LookRotation(-ray.direction);
        }
    }

    private void Shoot()
    {
        // Primero verificar si hay objetos SMALL absorbidos en el StateMachine
        if (stateMachine.HasAbsorbedSmallObjects())
        {
            // Obtener el primer objeto de la lista
            AbsorbableObject obj = stateMachine.GetFirstAbsorbedObject();
            
            if (obj != null)
            {
                // Posicionar objeto frente al jugador
                obj.transform.position = stateMachine.transform.position 
                    + Vector3.up * 1.5f 
                    + stateMachine.transform.forward * 2f;
                
                // Restaurar tamaño original
                obj.transform.localScale = Vector3.one;
                
                // Dirección de disparo (hacia donde apunta la cámara)
                Vector3 shootDirection = Camera.main.transform.forward;
                shootDirection.Normalize();
                
                // Disparar el objeto
                obj.ShootAsProjectile(shootDirection, stateMachine.GrayProjectileSpeedMultiplier);
                
                // Remover de la lista
                stateMachine.RemoveFirstAbsorbedObject();
                
                Debug.Log("Disparado objeto SMALL absorbido");
                return;
            }
        }
        
        // Disparo normal de tinta
        if (stateMachine.ProjectilePrefab == null || stateMachine.FirePoint == null) return;
        
       
        Rigidbody proj = UnityEngine.Object.Instantiate(stateMachine.ProjectilePrefab, stateMachine.FirePoint.position, Quaternion.identity);

        Vector3 direction = (_currentHitPoint - stateMachine.FirePoint.position).normalized;


        proj.linearVelocity = direction * speed;
        proj.useGravity = true;
        var inkProjectile = proj.GetComponent<InkProjectile>();
        if (inkProjectile != null)
        {
            inkProjectile.Initialize(stateMachine); 
        }
        
    }
    
    private bool TryGetBallisticVelocity(Vector3 origin, Vector3 target, float time, out Vector3 velocity)
    {
        float g = Physics.gravity.y;
        time = Mathf.Max(0.05f, time);
        Vector3 delta = target - origin;
        Vector3 deltaXZ = new Vector3(delta.x, 0f, delta.z);
        Vector3 vXZ = deltaXZ / time;
        float vY = (delta.y - 0.5f * g * time * time) / time;
        velocity = vXZ + Vector3.up * vY;
        return true;
    }
    
    private void HandleLookRotation(float deltaTime)
    {
        Vector2 lookInput = stateMachine.InputReader.LookVector;

        // Sensibilidad = valor base * sensibilidad del dispositivo actual (ratón o gamepad)
        float currentSensitivity = stateMachine.GetCurrentCameraSensitivity();
        float hSens = stateMachine.HorizontalSensitivity * currentSensitivity;
        float vSens = stateMachine.VerticalSensitivity * currentSensitivity;

        // Rotación horizontal - rota al jugador
        _rotationX += lookInput.x * hSens * deltaTime;

        // Aplicar rotación al jugador
        stateMachine.transform.rotation = Quaternion.Euler(0f, _rotationX, 0f);

        // Rotación vertical (opcional) - para inclinar la cámara
        _rotationY -= lookInput.y * vSens * deltaTime;
        _rotationY = Mathf.Clamp(_rotationY, stateMachine.MinVerticalAngle, stateMachine.MaxVerticalAngle);
        // Aquí aplicarías _rotationY a un pivot de cámara si lo necesitas
    }

    private void HandleAimMovement(float deltaTime)
    {
        Vector3 movementInput = new Vector3(stateMachine.InputReader.MoveVector.x, 0, stateMachine.InputReader.MoveVector.y);

        Vector3 forward = Camera.main.transform.forward;
        Vector3 right = Camera.main.transform.right;
        forward.y = 0;
        right.y = 0;
        forward.Normalize();
        right.Normalize();

        Vector3 moveDir = (forward * movementInput.z + right * movementInput.x);

        Move(moveDir * stateMachine.AimMovementSpeed, deltaTime);

        /*Vector3 lookDir = forward;
        if (lookDir != Vector3.zero)
        {
            stateMachine.transform.rotation = Quaternion.Slerp(
                stateMachine.transform.rotation,
                Quaternion.LookRotation(lookDir),
                stateMachine.RotationSpeed * deltaTime
            );
        }*/
    }
}