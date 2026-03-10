using UnityEngine;
using System.Collections.Generic;
using Unity.Cinemachine;

/// <summary>
/// Player Red State
/// - Everything on White State
/// - Can Shoot
/// </summary>
public class PlayerRedState : PlayerBaseState
{
    private readonly int FreeLookSpeedHash = Animator.StringToHash("SpeedX");
    private readonly int AnimationSpeedHash = Animator.StringToHash("AimSpeedX");
    private readonly int VerticalSpeedHash = Animator.StringToHash("SpeedY");
    private readonly int GroundedHash = Animator.StringToHash("IsGrounded");

    private readonly int FreeLookBlendTreeHash = Animator.StringToHash("FreeLookBlendTree");
    private readonly int WalkingBlendTreeHash = Animator.StringToHash("WalkingBlendTree");

    private readonly int StopRun = Animator.StringToHash("StopRun");

    private readonly int AnimJump = Animator.StringToHash("Impulse");
    
    private const float CrossFadeDuration = 0.1f;
    private const float AnimatorDampTime = 0.1f;
    
    private const float RunThreshold = 0.7f;
    private const float IdleThreshold = 0.05f;
    
    private float lastSpeed = 0f;
    private float lastInputMagnitude = 0f;
    
    public PlayerRedState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        Debug.Log("Entered PlayerGrayState - Vacuum Mode");
        
        // CAMERA IN
        stateMachine.mainCamera.Priority = 10;

        stateMachine.playerState = PlayerStates.RED;
        
        stateMachine.Animator.SetFloat(FreeLookSpeedHash, 0);
        stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);

        stateMachine.InputReader.JumpEvent += OnJump;
        stateMachine.InputReader.DiveEvent += OnDiveEnter;
        
        // Camera Settings
        if (stateMachine.mainCamera.Priority <= 9)
        {
            CameraRecenter();
            stateMachine.mainCamera.Priority = 10;
        }
        
        stateMachine.Animator.SetFloat(FreeLookSpeedHash, 0);
        
        stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
        lastSpeed = 0f;
        lastInputMagnitude = 0f;
    }

    public override void Tick(float deltaTime)
    {
        stateMachine.CheckGrounded();
        
        // TODO: Remove
        // Este color no tiene nada
        /*if (stateMachine.InputReader.isColorActing)
        {
            stateMachine.SwitchState(typeof(PlayerAbsorbState));
        }*/
        
        // Aim
        if (stateMachine.InputReader.isAiming)
        {
            stateMachine.SwitchState(typeof(PlayerShootingState));
            return;
        }
        
        Vector3 movement = stateMachine.CalculateMovement();
        float currentInputMagnitude = movement.magnitude;
        
        stateMachine.Animator.SetFloat(FreeLookSpeedHash, currentInputMagnitude, AnimatorDampTime, deltaTime);
        stateMachine.Animator.SetFloat(AnimationSpeedHash, movement.x, AnimatorDampTime, deltaTime);
        stateMachine.Animator.SetFloat(VerticalSpeedHash, stateMachine.Controller.velocity.y, AnimatorDampTime, deltaTime);
        stateMachine.Animator.SetBool(GroundedHash, stateMachine.isGrounded);
        
        // Blend tree switching basado en velocidad de input
        HandleBlendTreeTransition(currentInputMagnitude);
        if (currentInputMagnitude > RunThreshold)
        {
            FaceMovementDirection(movement, deltaTime);
        }
        
        float jumpTime = GetNormalizedTime(stateMachine.Animator, "Jump");

        if (jumpTime > 0.98f)
        {
            stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
        }

        stateMachine.Animator.SetFloat(FreeLookSpeedHash, movement.magnitude, AnimatorDampTime, deltaTime);
        
        if (!Equals(movement, Vector3.zero))
        {
            FaceMovementDirection(movement, deltaTime);
        }
        
        Move(movement * stateMachine.FreeLookMovementSpeed, deltaTime);
    }

    public override void Exit()
    {
        Debug.Log("Exiting PlayerGrayState");
        
        stateMachine.InputReader.JumpEvent -= OnJump;
        stateMachine.InputReader.DiveEvent -= OnDiveEnter;
        
        stateMachine.mainCamera.Priority = -1;
    }
    
    private void HandleBlendTreeTransition(float inputMagnitude)
    {
        if (inputMagnitude >= IdleThreshold && inputMagnitude < RunThreshold)
        {
            if (lastInputMagnitude < IdleThreshold || lastInputMagnitude >= RunThreshold)
                stateMachine.Animator.CrossFadeInFixedTime(WalkingBlendTreeHash, CrossFadeDuration);
        }
        else
        {
            if (lastInputMagnitude >= IdleThreshold && lastInputMagnitude < RunThreshold)
                stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
        }
    }
    
    private void FaceMovementDirection(Vector3 movement, float deltaTime)
    {
        stateMachine.transform.rotation = Quaternion.Lerp(
            stateMachine.transform.rotation,
            Quaternion.LookRotation(movement),
            deltaTime * stateMachine.RotationSpeed);
    }

    #region Base
    
    private void OnJump()
    {
        if (!CanJump()) return;
        stateMachine.Animator.CrossFadeInFixedTime(AnimJump, CrossFadeDuration);
        Jump();
    }

    private void OnDiveEnter()
    {
        stateMachine.SwitchState(typeof(PlayerSwimState));
    }
    
    private void CameraRecenter()
    {
        CinemachineOrbitalFollow orbitalFollow = stateMachine.mainCamera.gameObject.GetComponent<CinemachineOrbitalFollow>();
        
        float playerYaw = stateMachine.transform.eulerAngles.y;
        orbitalFollow.HorizontalAxis.Value = playerYaw;
        
        orbitalFollow.VerticalAxis.Value = orbitalFollow.VerticalAxis.Center;
        
        orbitalFollow.RadialAxis.Value = orbitalFollow.RadialAxis.Center;
    }

    #endregion
    
}
