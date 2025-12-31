using System;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class PlayerShootingState : PlayerBaseState
{
    public PlayerShootingState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    private float _nextFireTime;
    private Vector3 _currentHitPoint;
    private bool _hasHitTarget;

    private const float AimMovementSpeed = 3f;

    private float _rotationX;
    private float _rotationY;
    
    [SerializeField] private float horizontalSensitivity = 150f;
    [SerializeField] private float verticalSensitivity = 100f;
    [SerializeField] private float minVerticalAngle = -30f;
    [SerializeField] private float maxVerticalAngle = 60f;

    public override void Enter()
    {

        if (stateMachine.aimCamera != null)
            stateMachine.aimCamera.Priority.Value = 10;


        if (stateMachine.ReticleTransform != null)
            stateMachine.ReticleTransform.gameObject.SetActive(true);

        _rotationX = stateMachine.transform.eulerAngles.y;
        _rotationY = 0f;
    }

    public override void Tick(float deltaTime)
    {
        if (!stateMachine.InputReader.isAiming) 
        {
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
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

        if (stateMachine.aimCamera != null)
            stateMachine.aimCamera.Priority.Value = -1;

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
        if (stateMachine.ProjectilePrefab == null || stateMachine.FirePoint == null) return;

        Vector3 target = _currentHitPoint;

        
        if (TryGetBallisticVelocity(stateMachine.FirePoint.position, target, stateMachine.ProjectileFlightTime, out Vector3 velocity))
        {
            Rigidbody proj = UnityEngine.Object.Instantiate(stateMachine.ProjectilePrefab, stateMachine.FirePoint.position, Quaternion.identity);

            proj.linearVelocity = velocity;

            var inkProjectile = proj.GetComponent<InkProjectile>();
            if (inkProjectile != null)
            {
                inkProjectile.Initialize(stateMachine); 
            }
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

        // Sensibilidad (ajusta estos valores en PlayerStateMachine si quieres)
        float hSens = 150f;
        float vSens = 100f;

        // Rotación horizontal - rota al jugador
        _rotationX += lookInput.x * hSens * deltaTime;

        // Aplicar rotación al jugador
        stateMachine.transform.rotation = Quaternion.Euler(0f, _rotationX, 0f);

        // Rotación vertical (opcional) - para inclinar la cámara
        _rotationY -= lookInput.y * vSens * deltaTime;
        _rotationY = Mathf.Clamp(_rotationY, -30f, 60f);
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

        Move(moveDir * AimMovementSpeed, deltaTime);

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
