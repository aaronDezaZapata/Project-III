using UnityEngine;

/// <summary>
/// Estado que maneja el balanceo del jugador cuando se engancha a un GrapplePoint.
/// Implementa física de péndulo con balanceo automático CONTINUO en un PLANO VERTICAL.
/// El balanceo NUNCA se detiene.
/// </summary>
public class PlayerGreenState : PlayerBaseState
{
    private GrapplePoint currentGrapplePoint;
    private Vector3 grapplePosition;

    // Física del péndulo
    private float currentAngle;        
    private float angularVelocity;    
    private Vector3 swingPlaneNormal; 

    private bool isAttached;

    private const float Gravity = 9.81f;
    private const float Damping = 1.0f; 
    private const float EnergyBoost = 0.2f; 
    private const float MinAngularVelocity = 1.5f; 

    public PlayerGreenState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        Debug.Log("Entered PlayerGreenState - Grapple Mode (CONTINUOUS)");

        stateMachine.ForceReceiver.enabled = false;

        if (!TryFindGrapplePoint())
        {
            Debug.LogWarning("No se encontró ningún GrapplePoint válido. Saliendo del estado.");
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }

        AttachToGrapplePoint();

        if (stateMachine.GrappleRope != null)
        {
            stateMachine.GrappleRope.enabled = true;
        }

        stateMachine.InputReader.JumpEvent += OnDetach;
    }

    public override void Tick(float deltaTime)
    {
        if (!stateMachine.InputReader.isGreen)
        {
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }

        if (!isAttached) return;

        ApplyPendulumPhysics(deltaTime);

        MaintainMinimumEnergy();

        MovePlayer(deltaTime);

        RotatePlayer(deltaTime);

        UpdateRopeVisual();

        CheckRopeIntegrity();
    }

    public override void Exit()
    {
        Debug.Log("Exiting PlayerGreenState");

        stateMachine.InputReader.JumpEvent -= OnDetach;

        // ENDEREZAR AL JUGADOR 
        ForcePlayerUpright();

        stateMachine.ForceReceiver.enabled = true;

        if (stateMachine.GrappleRope != null)
        {
            stateMachine.GrappleRope.enabled = false;
        }

        ApplySwingMomentum();

        isAttached = false;
        currentGrapplePoint = null;
    }

    #region Grapple Logic

    private bool TryFindGrapplePoint()
    {
        GrapplePoint[] allPoints = Object.FindObjectsByType<GrapplePoint>(FindObjectsSortMode.None);
        GrapplePoint closestPoint = null;
        float closestDistance = float.MaxValue;

        Vector3 playerPos = stateMachine.transform.position;

        foreach (var point in allPoints)
        {
            if (!point.IsActive) continue;

            float distance = Vector3.Distance(playerPos, point.Position);

            if (distance > stateMachine.MaxGrappleDistance) continue;

            if (IsPathBlocked(playerPos, point.Position)) continue;

            if (distance < closestDistance)
            {
                closestDistance = distance;
                closestPoint = point;
            }
        }

        if (closestPoint != null)
        {
            currentGrapplePoint = closestPoint;
            grapplePosition = closestPoint.Position;
            return true;
        }

        return false;
    }

    private bool IsPathBlocked(Vector3 from, Vector3 to)
    {
        Vector3 direction = to - from;
        float distance = direction.magnitude;

        if (Physics.Raycast(from, direction.normalized, out RaycastHit hit, distance, stateMachine.GrappleObstacleLayer))
        {
            return hit.transform.GetComponent<GrapplePoint>() == null;
        }

        return false;
    }

    private void AttachToGrapplePoint()
    {
        isAttached = true;

        Vector3 toGrapple = grapplePosition - stateMachine.transform.position;
        float currentDistance = toGrapple.magnitude;

        if (currentDistance < stateMachine.SwingRadius)
        {
            Vector3 direction = toGrapple.normalized;
            stateMachine.transform.position = grapplePosition - direction * stateMachine.SwingRadius;
            toGrapple = grapplePosition - stateMachine.transform.position;
        }

        Vector3 ropeVector = stateMachine.transform.position - grapplePosition;

        Vector3 currentVelocity = stateMachine.Controller.velocity;
        Vector3 swingDirection;

        if (currentVelocity.magnitude > 0.5f)
        {
            swingDirection = currentVelocity;
        }
        else
        {
            swingDirection = Camera.main.transform.forward;
        }

        swingDirection.y = 0;
        swingDirection.Normalize();

        swingPlaneNormal = Vector3.Cross(Vector3.up, swingDirection).normalized;

        if (swingPlaneNormal.magnitude < 0.1f)
        {
            swingPlaneNormal = Camera.main.transform.right;
            swingPlaneNormal.y = 0;
            swingPlaneNormal.Normalize();
        }

        float verticalDistance = Mathf.Abs(grapplePosition.y - stateMachine.transform.position.y);
        currentAngle = Mathf.Acos(Mathf.Clamp(verticalDistance / stateMachine.SwingRadius, -1f, 1f));

        Vector3 horizontalOffset = stateMachine.transform.position - grapplePosition;
        horizontalOffset.y = 0;

        float side = Vector3.Dot(horizontalOffset, swingDirection);
        if (side < 0)
        {
            currentAngle = -currentAngle;
        }

        Vector3 tangentDirection = Vector3.Cross(swingPlaneNormal, ropeVector).normalized;
        float tangentialSpeed = Vector3.Dot(currentVelocity, tangentDirection);

        angularVelocity = tangentialSpeed / stateMachine.SwingRadius;

        if (Mathf.Abs(angularVelocity) < stateMachine.MinSwingSpeed)
        {
            float pushDirection = Vector3.Dot(swingDirection, tangentDirection);
            angularVelocity = stateMachine.MinSwingSpeed * Mathf.Sign(pushDirection);

            if (Mathf.Abs(angularVelocity) < 0.1f)
            {
                angularVelocity = stateMachine.MinSwingSpeed;
            }
        }

        Debug.Log($"Enganchado - Ángulo: {currentAngle * Mathf.Rad2Deg}°, Vel angular: {angularVelocity}");
    }

    #endregion

    #region Pendulum Physics

    private void ApplyPendulumPhysics(float deltaTime)
    {
        float angularAcceleration = -(Gravity / stateMachine.SwingRadius) * Mathf.Sin(currentAngle);

        ApplyPlayerInput(ref angularAcceleration, deltaTime);

        angularAcceleration += EnergyBoost * Mathf.Sign(angularVelocity);

        angularVelocity += angularAcceleration * deltaTime;
        angularVelocity *= Damping;

        currentAngle += angularVelocity * deltaTime;

        if (Mathf.Abs(currentAngle) > Mathf.PI * 0.5f)
        {
            currentAngle = Mathf.Sign(currentAngle) * Mathf.PI * 0.5f;
            angularVelocity = -angularVelocity * 0.8f;
        }
    }

    private void MaintainMinimumEnergy()
    {
        if (Mathf.Abs(angularVelocity) < MinAngularVelocity)
        {
            float boostDirection = Mathf.Sign(angularVelocity);
            if (boostDirection == 0) boostDirection = 1;

            angularVelocity = MinAngularVelocity * boostDirection;
        }
    }

    private void ApplyPlayerInput(ref float angularAcceleration, float deltaTime)
    {
        Vector2 input = stateMachine.InputReader.MoveVector;

        if (input.magnitude < 0.1f) return;

        Vector3 cameraForward = Camera.main.transform.forward;
        Vector3 cameraRight = Camera.main.transform.right;
        cameraForward.y = 0;
        cameraRight.y = 0;
        cameraForward.Normalize();
        cameraRight.Normalize();

        Vector3 inputDirection = (cameraForward * input.y + cameraRight * input.x).normalized;

        Vector3 ropeVector = stateMachine.transform.position - grapplePosition;
        Vector3 tangentDirection = Vector3.Cross(swingPlaneNormal, ropeVector).normalized;

        float alignment = Vector3.Dot(inputDirection, tangentDirection * Mathf.Sign(angularVelocity));

        if (alignment > 0.2f)
        {
            angularAcceleration += alignment * stateMachine.SwingInputForce;
        }
    }

    #endregion

    #region Movement & Rotation

    private void MovePlayer(float deltaTime)
    {
        float radius = stateMachine.SwingRadius;

        float verticalOffset = -radius * Mathf.Cos(currentAngle);
        float horizontalOffset = radius * Mathf.Sin(currentAngle);

        Vector3 horizontalDirection = Vector3.Cross(Vector3.up, swingPlaneNormal).normalized;

        Vector3 targetPosition = grapplePosition
            + Vector3.up * verticalOffset
            + horizontalDirection * horizontalOffset;

        Vector3 displacement = targetPosition - stateMachine.transform.position;
        stateMachine.Controller.Move(displacement);
    }

    private void RotatePlayer(float deltaTime)
    {
        Vector3 ropeVector = stateMachine.transform.position - grapplePosition;
        Vector3 movementDirection = Vector3.Cross(swingPlaneNormal, ropeVector).normalized;

        if (angularVelocity < 0)
        {
            movementDirection = -movementDirection;
        }

        if (movementDirection.sqrMagnitude > 0.01f)
        {
            Quaternion targetRotation = Quaternion.LookRotation(movementDirection);
            stateMachine.transform.rotation = Quaternion.Slerp(
                stateMachine.transform.rotation,
                targetRotation,
                stateMachine.RotationSpeed * 2f * deltaTime
            );
        }
    }

    /// <summary>
    /// FUERZA al jugador a estar completamente recto (vertical)
    /// </summary>
    private void ForcePlayerUpright()
    {
        // Guardar solo la rotación en Y (horizontal)
        float currentYRotation = stateMachine.transform.eulerAngles.y;

        // Crear una rotación completamente vertical (solo gira en Y)
        stateMachine.transform.rotation = Quaternion.Euler(0f, currentYRotation, 0f);

        Debug.Log($"Jugador enderezado - Rotación Y: {currentYRotation}°");
    }

    #endregion

    #region Rope & Visual

    private void UpdateRopeVisual()
    {
        if (stateMachine.GrappleRope == null) return;

        Vector3 startPoint = stateMachine.GrappleRopeOrigin != null
            ? stateMachine.GrappleRopeOrigin.position
            : stateMachine.transform.position + Vector3.up * 1.5f;

        stateMachine.GrappleRope.SetPosition(0, startPoint);
        stateMachine.GrappleRope.SetPosition(1, grapplePosition);
    }

    private void CheckRopeIntegrity()
    {
        float currentDistance = Vector3.Distance(stateMachine.transform.position, grapplePosition);

        if (currentDistance > stateMachine.MaxGrappleDistance * 1.2f)
        {
            Debug.Log("Cuerda rota - demasiado alejado");
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
        }
    }

    #endregion

    #region Exit Actions

    private void ApplySwingMomentum()
    {
        float linearSpeed = angularVelocity * stateMachine.SwingRadius;

        Vector3 ropeVector = stateMachine.transform.position - grapplePosition;
        Vector3 momentumDirection = Vector3.Cross(swingPlaneNormal, ropeVector).normalized;

        Vector3 momentum = momentumDirection * linearSpeed;
        momentum += Vector3.up * stateMachine.GrappleJumpForce;

        stateMachine.ForceReceiver.AddForce(momentum);

        Debug.Log($"Soltado con momento: {momentum.magnitude:F2}");
    }

    private void OnDetach()
    {
        stateMachine.SwitchState(typeof(PlayerFreeLookState));
    }

    #endregion
}