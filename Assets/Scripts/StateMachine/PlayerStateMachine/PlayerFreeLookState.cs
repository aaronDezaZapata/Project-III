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

        //stateMachine.InputReader.DashEvent += OnDash;

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
        if (stateMachine.InputReader.isGray && stateMachine.HasGrayAbility)
        {
            stateMachine.SwitchState(typeof(PlayerGrayState));
            return;
        }

        // Enemigos latigo
        if (stateMachine.InputReader.isGreen && stateMachine.HasGreenAbility)
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
        }

        // Aim
        if (stateMachine.InputReader.isAiming)
        {
            stateMachine.SwitchState(typeof(PlayerShootingState));
            return;
        }

        Vector3 movement = CalculateMovement();
        float currentInputMagnitude = movement.magnitude;
        lastSpeed = movement.normalized.magnitude;
        stateMachine.Animator.SetFloat(FreeLookSpeedHash, movement.normalized.magnitude, AnimatorDampTime, deltaTime);

        if (currentInputMagnitude < 0.01f && lastSpeed > RunThreshold)
        {
            stateMachine.Animator.CrossFadeInFixedTime(StopRun, CrossFadeDuration);
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

    #region Green Ability Detection

    private bool HasNearbyEnemy()
    {
        Collider[] enemies = Physics.OverlapSphere(
            stateMachine.transform.position,
            stateMachine.EnemyDetectionRange,
            stateMachine.EnemyLayer
        );

        // Si hay al menos un enemigo en rango
        if (enemies.Length > 0)
        {
            // Verificar que al menos uno sea visible (sin obst�culos)
            foreach (Collider enemy in enemies)
            {
                Vector3 dirToEnemy = enemy.transform.position - stateMachine.transform.position;
                float distToEnemy = dirToEnemy.magnitude;

                // Raycast para verificar l�nea de visi�n
                int layerMask = ~stateMachine.EnemyLayer; // Ignorar enemigos

                if (!Physics.Raycast(
                    stateMachine.transform.position + Vector3.up,
                    dirToEnemy.normalized,
                    distToEnemy,
                    layerMask))
                {
                    return true; // Hay al menos un enemigo visible
                }
            }
        }

        return false;
    }

    private bool HasNearbyGrapplePoint()
    {
        GrapplePoint[] allPoints = Object.FindObjectsByType<GrapplePoint>(FindObjectsSortMode.None);

        foreach (var point in allPoints)
        {
            if (!point.IsActive) continue;

            float distance = Vector3.Distance(stateMachine.transform.position, point.Position);

            if (distance <= stateMachine.MaxGrappleDistance)
            {
                // Verificar que no haya obst�culos
                Vector3 dirToPoint = point.Position - stateMachine.transform.position;

                if (!Physics.Raycast(
                    stateMachine.transform.position + Vector3.up,
                    dirToPoint.normalized,
                    distance,
                    stateMachine.GrappleObstacleLayer))
                {
                    return true; // Hay al menos un punto accesible
                }
            }
        }

        return false;
    }

    #endregion
    private void FaceMovementDirection(Vector3 movement, float deltaTime)
    {
        stateMachine.transform.rotation = Quaternion.Lerp(
            stateMachine.transform.rotation,
            Quaternion.LookRotation(movement),
            deltaTime * stateMachine.RotationSpeed);
        
    }
    
    Vector3 CalculateMovement()
    {
        Vector3 forward = Camera.main.transform.forward;
        Vector3 right = Camera.main.transform.right;

        forward.y = 0f;
        right.y = 0f;

        forward.Normalize();
        right.Normalize();

        return forward * stateMachine.InputReader.MoveVector.y + right * stateMachine.InputReader.MoveVector.x;
    }
    
    private void OnJump()
    {
        if (!stateMachine.Controller.isGrounded) return;
        Jump();
    }

    private void OnDiveEnter()
    {
        stateMachine.SwitchState(typeof(PlayerSwimState));
    }

    private void OnGreenActivated()
    {
        if (stateMachine.HasGreenAbility)
        {
            stateMachine.SwitchState(typeof(PlayerGreenState));
        }
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
