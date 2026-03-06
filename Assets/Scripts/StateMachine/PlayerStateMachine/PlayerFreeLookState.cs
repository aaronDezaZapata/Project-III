using System.Collections;
using System.Collections.Generic;
using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.Rendering.Universal.Internal;

/// <summary>
/// Clase Black Base
/// - Plain Shoot
/// - Player impulses himself into enemies as attack
/// </summary>
public class PlayerFreeLookState : PlayerBaseState
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
    
    public PlayerFreeLookState(PlayerStateMachine stateMachine) : base(stateMachine)
    { 
    }


    public override void Enter()
    {
        Debug.Log("Entered PlayerFreeLookState");

        stateMachine.playerState = PlayerStates.BLACK;
        
        stateMachine.Mat_Player.material.SetColor("_SpecularColor", Color.white);
        
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
        if (stateMachine.InputReader.isColorActing && stateMachine.HasDashAttack)
        {
            if (HasNearbyPaintedEnemy())
            {
                stateMachine.SwitchState(typeof(PlayerDashAttackState));
                return;
            }
        }
        
        // TODO: Remove
        // Idle/Transparent state
        /*if (stateMachine.InputReader.isAiming)
        {
            stateMachine.SwitchState(typeof(PlayerShootingState));
            return;
        }*/

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

        // Cuando termina el salto
        float jumpTime = GetNormalizedTime(stateMachine.Animator, "Jump");
        if (jumpTime > 0.98f)
        {
            HandleBlendTreeTransition(currentInputMagnitude);

            if (currentInputMagnitude > RunThreshold)
            {
                stateMachine.Animator.CrossFadeInFixedTime(StopRun, CrossFadeDuration);
            }
        }

        Move(movement * stateMachine.FreeLookMovementSpeed, deltaTime);

        lastSpeed = currentInputMagnitude;
        lastInputMagnitude = currentInputMagnitude;
    }

    public override void Exit()
    {
        stateMachine.InputReader.JumpEvent -= OnJump;
        // stateMachine.InputReader.DashEvent -= OnDash;
        stateMachine.InputReader.DiveEvent -= OnDiveEnter;
        
        // Camera Out
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
    
    // TODO: Check a timer for a valid TP
    // CHECKER IF WE HAVE A PAINTED BEACON
    private bool HasNearbyPaintedEnemy()
    {
        return GameManager.Instance.paintBeacon;
    }
    
    private void FaceMovementDirection(Vector3 movement, float deltaTime)
    {
        stateMachine.transform.rotation = Quaternion.Lerp(
            stateMachine.transform.rotation,
            Quaternion.LookRotation(movement),
            deltaTime * stateMachine.RotationSpeed);
    }
    
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
}
