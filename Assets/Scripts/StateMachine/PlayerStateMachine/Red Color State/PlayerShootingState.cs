using System;
using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class PlayerShootingState : PlayerBaseState
{
    public static Action<bool> OnAiming;
    private static readonly int IsOnShooting = Animator.StringToHash("IsOnShooting");
    
    private float _speed = 100f;
    private float _nextFireTime;
    private float _rotationX;
    private float _rotationY;

    private float _currentDirX;
    private float _currentDirY;

    //Audio
    private bool wasFiringAudio;

    public PlayerShootingState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        SyncAimCameraWithOrbital();
        
        stateMachine.aimCamera.Priority = 10;
        
        stateMachine.Animator.SetBool(IsOnShooting, true);

        if (stateMachine.ReticleTransform != null)
            stateMachine.ReticleTransform.gameObject.SetActive(true);
        
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
        
        _currentDirX = Mathf.Lerp(_currentDirX, stateMachine.InputReader.MoveVector.x, Time.deltaTime * 15f);
        _currentDirY = Mathf.Lerp(_currentDirY, stateMachine.InputReader.MoveVector.y, Time.deltaTime * 15f);
        
        stateMachine.Animator.SetFloat("DirX", _currentDirX);
        stateMachine.Animator.SetFloat("DirY", _currentDirY);
        
        Vector3 movement = stateMachine.CalculateMovement();

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
        
        SyncOrbitalWithAimCamera();
        
        stateMachine.aimCamera.Priority = -1;
        
        OnAiming?.Invoke(false);
        
        if (stateMachine.ReticleTransform != null)
            stateMachine.ReticleTransform.gameObject.SetActive(false);
        
        stateMachine.Animator.SetBool(IsOnShooting, false);
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

        proj.linearVelocity = direction * _speed;
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
        
        orbitalFollow.VerticalAxis.Value = pitchAngle;
    }
}