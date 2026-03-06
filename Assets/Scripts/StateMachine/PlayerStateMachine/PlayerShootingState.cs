using System;
using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class PlayerShootingState : PlayerBaseState
{
    private readonly int ShootAnim = Animator.StringToHash("Shoot");
    private const float CrossFadeDuration = 0.1f;
    float speed = 100f;

    public static Action<bool> isAiming;
    
    public PlayerShootingState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    private float _nextFireTime;

    private float _rotationX;
    private float _rotationY;

    public override void Enter()
    {
        // stateMachine.FaceMovementDirectionInstant(Camera.main.transform.forward);
        
        // Sincronizar la dirección de la cámara de apuntado con la orbital
        SyncAimCameraWithOrbital();
        
        isAiming?.Invoke(true);
        
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
        
        HandleAimMovement(deltaTime);

        
        if (stateMachine.InputReader.IsFiring && Time.time >= _nextFireTime)
        {
            Shoot();
            _nextFireTime = Time.time + stateMachine.FireCooldown;
        }
    }

    public override void Exit()
    {
        // Sincronizar la cámara orbital con la dirección de la cámara de apuntado
        SyncOrbitalWithAimCamera();
        
        stateMachine.aimCamera.Priority = -1;
        
        isAiming?.Invoke(false);
        
        if (stateMachine.ReticleTransform != null)
            stateMachine.ReticleTransform.gameObject.SetActive(false);
    }

    private void Shoot()
    {
        if (stateMachine.ProjectilePrefab == null || stateMachine.FirePoint == null) return;
        
        Rigidbody proj = UnityEngine.Object.Instantiate(stateMachine.ProjectilePrefab, stateMachine.FirePoint.position, Quaternion.identity);
        
        Vector3 direction = Camera.main.transform.forward;

        proj.linearVelocity = direction * speed;
        proj.useGravity = true;
        var inkProjectile = proj.GetComponent<InkProjectile>();
        if (inkProjectile != null)
        {
            inkProjectile.Initialize(stateMachine); 
        }
    }
    
    // TODO: Remove
    // No lo usamos
    /*private bool TryGetBallisticVelocity(Vector3 origin, Vector3 target, float time, out Vector3 velocity)
    {
        float g = Physics.gravity.y;
        time = Mathf.Max(0.05f, time);
        Vector3 delta = target - origin;
        Vector3 deltaXZ = new Vector3(delta.x, 0f, delta.z);
        Vector3 vXZ = deltaXZ / time;
        float vY = (delta.y - 0.5f * g * time * time) / time;
        velocity = vXZ + Vector3.up * vY;
        return true;
    }*/
    
    private void HandleLookRotation(float deltaTime)
    {
        Vector2 lookInput = stateMachine.InputReader.LookVector;
        
        float currentSensitivity = stateMachine.GetCurrentCameraSensitivity();
        float hSens = stateMachine.HorizontalSensitivity * currentSensitivity;
        float vSens = stateMachine.VerticalSensitivity * currentSensitivity;
        
        _rotationX += lookInput.x * hSens * deltaTime;
        
        stateMachine.transform.rotation = Quaternion.Euler(0f, _rotationX, 0f);
        
        _rotationY -= lookInput.y * vSens * deltaTime;
        _rotationY = Mathf.Clamp(_rotationY, stateMachine.MinVerticalAngle, stateMachine.MaxVerticalAngle);
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

    private void SyncAimCameraWithOrbital()
    {
        Vector3 orbitalForward = stateMachine.mainCamera.transform.forward;
        
        Vector3 forwardFlat = new Vector3(orbitalForward.x, 0f, orbitalForward.z).normalized;
        if (forwardFlat != Vector3.zero)
        {
            float yawAngle = Mathf.Atan2(forwardFlat.x, forwardFlat.z) * Mathf.Rad2Deg;
            
            stateMachine.transform.rotation = Quaternion.Euler(0f, yawAngle, 0f);
            _rotationX = yawAngle;
        }
        
        float pitchAngle = -Mathf.Asin(orbitalForward.y) * Mathf.Rad2Deg;
        
        if (stateMachine.aimCameraPitchControl != null)
        {
            stateMachine.aimCameraPitchControl.SetPitch(pitchAngle);
        }
    }
    
    private void SyncOrbitalWithAimCamera()
    {
        CinemachineOrbitalFollow orbitalFollow = stateMachine.mainCamera.gameObject.GetComponent<CinemachineOrbitalFollow>();
        if (orbitalFollow == null) return;
        
        float playerYaw = stateMachine.transform.eulerAngles.y;
        orbitalFollow.HorizontalAxis.Value = playerYaw;
        
        Vector3 aimForward = stateMachine.aimCamera.transform.forward;
        
        float pitchAngle = -Mathf.Asin(aimForward.y) * Mathf.Rad2Deg;
        
        float normalizedPitch = Mathf.InverseLerp(stateMachine.MinVerticalAngle, stateMachine.MaxVerticalAngle, pitchAngle);
        
        orbitalFollow.VerticalAxis.Value = normalizedPitch;
    }
}