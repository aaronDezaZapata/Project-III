using System;
using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class PlayerShootingState : PlayerBaseState
{
    private readonly int ShootAnim = Animator.StringToHash("Shoot");
    private readonly int WalkingBlendTreeHash = Animator.StringToHash("WalkingBlendTree");
    private readonly int FreeLookBlendTreeHash = Animator.StringToHash("FreeLookBlendTree");
    private readonly int FreeLookSpeedHash = Animator.StringToHash("SpeedX");
    private const float CrossFadeDuration = 0.1f;
    private const float AnimatorDampTime = 0.1f;

    public static Action<bool> OnAiming;
    
    private float speed = 100f;
    private float _nextFireTime;
    private float _rotationX;
    private float _rotationY;

    //Audio
    private bool wasFiringAudio;

    public PlayerShootingState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        // Sincronizar la dirección de la cámara de apuntado con la orbital
        SyncAimCameraWithOrbital();
        
        // CAMERA IN
        stateMachine.aimCamera.Priority = 10;
        
        // Activar el WalkingBlendTree cuando entras al estado de shooting
        stateMachine.Animator.CrossFadeInFixedTime(WalkingBlendTreeHash, CrossFadeDuration);

        if (stateMachine.ReticleTransform != null)
            stateMachine.ReticleTransform.gameObject.SetActive(true);
        
        // Aim Panel
        OnAiming?.Invoke(true);
        
        _rotationX = stateMachine.transform.eulerAngles.y;
        _rotationY = 0f;
        wasFiringAudio = false;
    }

    public override void Tick(float deltaTime)
    {
        if (!stateMachine.InputReader.isAiming) 
        {
            StopPaintAudio();
            stateMachine.ReturnToMainState();
            return;
        }
        
        HandleLookRotation(deltaTime);
        HandleAimMovement(deltaTime);

        // Actualizar la velocidad de movimiento en el animator
        Vector3 movement = stateMachine.CalculateMovement();
        stateMachine.Animator.SetFloat(FreeLookSpeedHash, movement.magnitude, AnimatorDampTime, deltaTime);

        if (stateMachine.InputReader.IsFiring)
        {
            if (!wasFiringAudio)
            {
                stateMachine.PlayerAudio?.PlayPaintStart();
                stateMachine.PlayerAudio?.StartPaintLoop();
                wasFiringAudio = true;
            }

            if (Time.time >= _nextFireTime)
            {
                Shoot();
                _nextFireTime = Time.time + stateMachine.FireCooldown;
            }
        }
        else
        {
            StopPaintAudio();
        }
    }

    public override void Exit()
    {
        StopPaintAudio();

        // Sincronizar la cámara orbital con la dirección de la cámara de apuntado
        SyncOrbitalWithAimCamera();
        
        stateMachine.aimCamera.Priority = -1;
        
        OnAiming?.Invoke(false);
        
        if (stateMachine.ReticleTransform != null)
            stateMachine.ReticleTransform.gameObject.SetActive(false);
        
        // Volver al FreeLookBlendTree al salir
        stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
    }

    private void StopPaintAudio()
    {
        if (!wasFiringAudio) return;

        stateMachine.PlayerAudio?.StopPaintLoop();
        stateMachine.PlayerAudio?.PlayPaintEnd();
        wasFiringAudio = false;
    }

    private void Shoot()
    {
        if (stateMachine.ProjectilePrefab == null || stateMachine.FirePoint == null) return;

        Rigidbody proj = UnityEngine.Object.Instantiate(
            stateMachine.ProjectilePrefab,
            stateMachine.FirePoint.position,
            Quaternion.identity
        );
        
        Vector3 direction = Camera.main.transform.forward;
        stateMachine.UseColor(0.1f);

        proj.linearVelocity = direction * speed;
        proj.useGravity = true;

        var inkProjectile = proj.GetComponent<InkProjectile>();
        if (inkProjectile != null)
        {
            inkProjectile.Initialize(stateMachine); 
        }
    }
    
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
        
        // Cinemachine 3 OrbitalFollow VerticalAxis expects degrees, not a 0-1 normalized value.
        orbitalFollow.VerticalAxis.Value = pitchAngle;
    }
}