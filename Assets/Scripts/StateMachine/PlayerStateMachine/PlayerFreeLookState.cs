using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal.Internal;

/// <summary>
/// PlayerFreeLookState con lógica para decidir entre:
/// - PlayerGreenState (balanceo en GrapplePoints)
/// - PlayerGreenWhipState (látigo para enemigos)
/// </summary>
public class PlayerFreeLookState : PlayerBaseState
{

    public PlayerFreeLookState(PlayerStateMachine stateMachine) : base(stateMachine)
    { 
       
    }


    public override void Enter()
    {
        Debug.Log("Entered PlayerFreeLookState");
        stateMachine.InputReader.JumpEvent += OnJump;

        //stateMachine.InputReader.DashEvent += OnDash;

        stateMachine.InputReader.DiveEvent += OnDiveEnter;
    }

  

    public override void Tick(float deltaTime)
    {
        /*stateMachine.CheckForInk();
        if (Input.GetMouseButton(0))
        {
            stateMachine.ShootInk();
        }

      
        if (Input.GetKeyDown(KeyCode.B) && stateMachine.IsOnInk)
        {
            stateMachine.SwitchState(typeof(PlayerSwimState));
            return;
        }*/

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
                // Usar mecánica de látigo
                stateMachine.SwitchState(typeof(PlayerGreenWhipState));
                return;
            }
            // Si no hay enemigos, buscar GrapplePoints
            else if (HasNearbyGrapplePoint())
            {
                // Usar mecánica de balanceo
                stateMachine.SwitchState(typeof(PlayerGreenState));
                return;
            }
            // Si no hay ni enemigos ni puntos, no hacer nada
            // (el jugador puede seguir moviéndose con el botón presionado)
        }

        // Aim
        if (stateMachine.InputReader.isAiming)
        {
            stateMachine.SwitchState(typeof(PlayerShootingState));
            return;
        }

        // Heiser
        if (stateMachine.InputReader.isHeiser)
        {
            stateMachine.SwitchState(typeof(PlayerHeiserState));
            return;
        }


        Vector3 movement = CalculateMovement();
       
        if (!Equals(movement, Vector3.zero))
        {
            FaceMovementDirection(movement, deltaTime);
        }

        Move(movement * stateMachine.FreeLookMovementSpeed, deltaTime);
    }

    public override void Exit()
    {

        stateMachine.InputReader.JumpEvent -= OnJump;

        // stateMachine.InputReader.DashEvent -= OnDash;
        
        stateMachine.InputReader.DiveEvent -= OnDiveEnter;
    }

    #region Green Ability Detection

    /// <summary>
    /// Verifica si hay enemigos cercanos para la mecánica de látigo
    /// </summary>
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
            // Verificar que al menos uno sea visible (sin obstáculos)
            foreach (Collider enemy in enemies)
            {
                Vector3 dirToEnemy = enemy.transform.position - stateMachine.transform.position;
                float distToEnemy = dirToEnemy.magnitude;

                // Raycast para verificar línea de visión
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

    /// <summary>
    /// Verifica si hay GrapplePoints cercanos para la mecánica de balanceo
    /// </summary>
    private bool HasNearbyGrapplePoint()
    {
        GrapplePoint[] allPoints = Object.FindObjectsByType<GrapplePoint>(FindObjectsSortMode.None);

        foreach (var point in allPoints)
        {
            if (!point.IsActive) continue;

            float distance = Vector3.Distance(stateMachine.transform.position, point.Position);

            if (distance <= stateMachine.MaxGrappleDistance)
            {
                // Verificar que no haya obstáculos
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

    private void FaceMovementDirectionInstant(Vector3 movement)
    {
        stateMachine.transform.rotation = Quaternion.LookRotation(movement);
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



    /*private void OnDash()
    {
        if (stateMachine.InputReader.MoveVector == Vector2.zero) { return; }

       //stateMachine.SwitchState(PlayerDashingState);
    }*/


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
}
