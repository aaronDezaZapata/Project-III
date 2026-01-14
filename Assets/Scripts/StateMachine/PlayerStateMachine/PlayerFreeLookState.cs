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
    private readonly int FreeLookSpeedHash = Animator.StringToHash("Speed");

    private readonly int FreeLookBlendTreeHash = Animator.StringToHash("FreeLookBlendTree");

    private readonly int StopRun = Animator.StringToHash("StopRun");

    private readonly int AnimJump = Animator.StringToHash("Jump");

    private const float CrossFadeDuration = 0.1f;

    private const float AnimatorDampTime = 0.1f;

    private const float RunThreshold = 0.8f;

    private float lastSpeed = 0f;
    private float lastInputMagnitude = 0f;
    public PlayerFreeLookState(PlayerStateMachine stateMachine) : base(stateMachine)
    { 
       
    }


    public override void Enter()
    {
        Debug.Log("Entered PlayerFreeLookState");

        stateMachine.playerState = PlayerStates.BLACK;
        
        stateMachine.InputReader.JumpEvent += OnJump;

        // stateMachine.InputReader.ColorActionEvent += OnHeiserEnter;

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
        /*if (stateMachine.InputReader.isGray && stateMachine.HasGrayAbility)
        {
            stateMachine.SwitchState(typeof(PlayerGrayState));
            return;
        }*/
        
        // TESTING
        /*if (stateMachine.InputReader.isColorActing)
        {
            stateMachine.SwitchState(typeof(PlayerDashAttackState));
            return;
        }*/
        
        if (stateMachine.InputReader.isColorActing && stateMachine.HasDashAttack)
        {
            if (HasNearbyPaintedEnemy())
            {
                stateMachine.SwitchState(typeof(PlayerDashAttackState));
                return;
            }
        }

        // Enemigos latigo
        /*if (stateMachine.InputReader.isGreen && stateMachine.HasGreenAbility)
        {
            // Primero buscar enemigos (mayor prioridad)
            if (HasNearbyEnemy())
            {
                // Usar mec�nica de l�tigo
                stateMachine.SwitchState(typeof(PlayerGreenWhipState));
                return;
            }
            // Si no hay enemigos, buscar GrapplePoints
            else if (HasNearbyGrapplePoint())
            {
                // Usar mec�nica de balanceo
                stateMachine.SwitchState(typeof(PlayerGreenState));
                return;
            }
            // Si no hay ni enemigos ni puntos, no hacer nada
            // (el jugador puede seguir movi�ndose con el bot�n presionado)
        }*/

        // Aim
        if (stateMachine.InputReader.isAiming)
        {
            stateMachine.SwitchState(typeof(PlayerShootingState));
            return;
        }

        Vector3 movement = stateMachine.CalculateMovement();
        float currentInputMagnitude = movement.magnitude;
        lastSpeed = movement.magnitude;

        stateMachine.Animator.SetFloat(FreeLookSpeedHash, movement.magnitude, AnimatorDampTime, deltaTime);
       
        if (currentInputMagnitude < 0.01f && lastSpeed > RunThreshold)
        {
            stateMachine.Animator.CrossFadeInFixedTime(StopRun, CrossFadeDuration);
        }

        if(GetNormalizedTime(stateMachine.Animator, "Jump") >= 1f)
        {
            stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
        }


        if (!Equals(movement, Vector3.zero))
        {
            FaceMovementDirection(movement, deltaTime);
            stateMachine.Animator.SetFloat(FreeLookSpeedHash, movement.normalized.magnitude, AnimatorDampTime, deltaTime);
        }

        Move(movement * stateMachine.FreeLookMovementSpeed, deltaTime);

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
    
    // CHECKER IF WE HAVE A PAINTED ENEMY
    private bool HasNearbyPaintedEnemy()
    {
        return GameManager.Instance.enemiesPainted.Count > 0;
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

    private void CameraRecenter()
    {
        CinemachineOrbitalFollow orbitalFollow = stateMachine.mainCamera.gameObject.GetComponent<CinemachineOrbitalFollow>();
        
        float playerYaw = stateMachine.transform.eulerAngles.y;
        orbitalFollow.HorizontalAxis.Value = playerYaw;
        
        orbitalFollow.VerticalAxis.Value = orbitalFollow.VerticalAxis.Center;
        
        orbitalFollow.RadialAxis.Value = orbitalFollow.RadialAxis.Center;
    }
}
