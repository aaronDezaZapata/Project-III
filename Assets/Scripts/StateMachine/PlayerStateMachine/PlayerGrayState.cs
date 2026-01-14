using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// Estado que maneja la mecánica de aspiradora (gris).
/// Absorbe objetos y enemigos, los almacena y los lanza como proyectiles.
/// </summary>
public class PlayerGrayState : PlayerBaseState
{
    private readonly int FreeLookSpeedHash = Animator.StringToHash("Speed");
    private readonly int FreeLookBlendTreeHash = Animator.StringToHash("FreeLookBlendTree");
    private readonly int AnimJump = Animator.StringToHash("Jump");
    
    private const float AnimatorDampTime = 0.1f;

    private const float CrossFadeDuration = 0.1f;
    public PlayerGrayState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        Debug.Log("Entered PlayerGrayState - Vacuum Mode");
        
        // CAMERA IN
        stateMachine.mainCamera.Priority = 10;

        stateMachine.InputReader.JumpEvent += OnJump;
        stateMachine.InputReader.DiveEvent += OnDiveEnter;
        
    }

    public override void Tick(float deltaTime)
    {
        if (stateMachine.InputReader.isColorActing)
        {
            stateMachine.SwitchState(typeof(PlayerAbsorbState));
        }
        
        // Aim
        if (stateMachine.InputReader.isAiming)
        {
            stateMachine.SwitchState(typeof(PlayerShootingState));
            return;
        }
        
        Vector3 movement = stateMachine.CalculateMovement();
        
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
        if (!stateMachine.Controller.isGrounded) return;
        stateMachine.Animator.CrossFadeInFixedTime(AnimJump, CrossFadeDuration);
        Jump();
    }
    
    private void OnDiveEnter()
    {
        stateMachine.SwitchState(typeof(PlayerSwimState));
    }
}
