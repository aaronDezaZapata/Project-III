using UnityEngine;

/// <summary>
/// Estado que maneja la mecánica de látigo del jugador.
/// Captura enemigos, los gira en círculo y los lanza.
/// </summary>
public class PlayerGreenWhipState : PlayerBaseState
{
    private Transform capturedEnemy;
    private Rigidbody capturedEnemyRb;
    private EnemyScript capturedEnemyScript;
    private Vector3 captureOffset;

    // Física del giro
    private float currentRotationSpeed;
    private float spinAngle;

    // Control de estado
    private bool isHolding;
    private bool isCapturing;

    public PlayerGreenWhipState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        Debug.Log("Entered PlayerGreenWhipState - Whip Mode");

        stateMachine.ForceReceiver.enabled = false;

        if (!TryFindEnemy())
        {
            Debug.LogWarning("No se encontró enemigo válido. Saliendo del estado.");
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }

        StartCapture();

        // Mostrar cuerda visual
        if (stateMachine.GrappleRope != null)
        {
            stateMachine.GrappleRope.enabled = true;
        }

        // Suscribirse al evento de ataque para soltar
        stateMachine.InputReader.JumpEvent += OnRelease;
    }

    public override void Tick(float deltaTime)
    {
        // Si suelta el botón verde, volver a FreeLook
        if (!stateMachine.InputReader.isGreen)
        {
            ReleaseEnemy();
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }

        if (isCapturing)
        {
            UpdateCapture(deltaTime);
        }
        else if (isHolding)
        {
            UpdateSpin(deltaTime);
            UpdateRopeVisual();
        }
    }

    public override void Exit()
    {
        Debug.Log("Exiting PlayerGreenWhipState");

        stateMachine.InputReader.JumpEvent -= OnRelease;

        stateMachine.ForceReceiver.enabled = true;

        if (stateMachine.GrappleRope != null)
        {
            stateMachine.GrappleRope.enabled = false;
        }

        // Asegurar que el enemigo se libere si aún está capturado
        if (capturedEnemy != null && isHolding)
        {
            ReleaseEnemy();
        }
    }

    #region Enemy Detection & Capture

    private bool TryFindEnemy()
    {
        // Buscar enemigos en rango
        Collider[] enemies = Physics.OverlapSphere(
            stateMachine.transform.position,
            stateMachine.MaxGrappleDistance,
            stateMachine.EnemyLayer
        );

        Transform bestEnemy = null;
        float closestDistance = float.MaxValue;

        foreach (Collider col in enemies)
        {
            Transform enemy = col.transform;
            float distance = Vector3.Distance(stateMachine.transform.position, enemy.position);

            // Verificar que no haya obstáculos
            if (IsPathBlocked(stateMachine.transform.position, enemy.position))
                continue;

            if (distance < closestDistance)
            {
                closestDistance = distance;
                bestEnemy = enemy;
            }
        }

        if (bestEnemy != null)
        {
            capturedEnemy = bestEnemy;
            capturedEnemyRb = bestEnemy.GetComponent<Rigidbody>();
            capturedEnemyScript = bestEnemy.GetComponent<EnemyScript>();
            return true;
        }

        return false;
    }

    private bool IsPathBlocked(Vector3 from, Vector3 to)
    {
        Vector3 direction = to - from;
        float distance = direction.magnitude;

        // Raycast ignorando enemigos
        int layerMask = ~stateMachine.EnemyLayer;

        if (Physics.Raycast(from, direction.normalized, out RaycastHit hit, distance, layerMask))
        {
            return true;
        }

        return false;
    }

    private void StartCapture()
    {
        isCapturing = true;
        isHolding = false;

        // Notificar al enemigo que está siendo capturado
        if (capturedEnemyScript != null)
        {
            capturedEnemyScript.Stun(true);
        }

        // Hacer el enemigo kinematic mientras se captura
        if (capturedEnemyRb != null)
        {
            capturedEnemyRb.isKinematic = true;
        }

        Debug.Log($"Capturando enemigo: {capturedEnemy.name}");
    }

    private void UpdateCapture(float deltaTime)
    {
        if (capturedEnemy == null)
        {
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }

        // Posición objetivo (encima del jugador)
        Vector3 targetPosition = stateMachine.transform.position
            + Vector3.up * stateMachine.WhipHoldHeight
            + stateMachine.transform.forward * stateMachine.WhipHoldRadius;

        // Mover enemigo hacia la posición objetivo
        capturedEnemy.position = Vector3.Lerp(
            capturedEnemy.position,
            targetPosition,
            stateMachine.WhipCaptureSpeed * deltaTime
        );

        // Cuando esté cerca, empezar a girar
        float distanceToTarget = Vector3.Distance(capturedEnemy.position, targetPosition);
        if (distanceToTarget < 0.3f)
        {
            isCapturing = false;
            isHolding = true;
            currentRotationSpeed = stateMachine.WhipStartSpinSpeed;
            spinAngle = 0f;

            Debug.Log("Enemigo capturado - Iniciando giro");
        }
    }

    #endregion

    #region Spin Mechanics

    private void UpdateSpin(float deltaTime)
    {
        if (capturedEnemy == null)
        {
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }

        // Acelerar el giro con input del jugador
        Vector2 input = stateMachine.InputReader.MoveVector;

        if (input.magnitude > 0.1f)
        {
            currentRotationSpeed += stateMachine.WhipSpinAcceleration * deltaTime;
        }
        else
        {
            // Desacelerar ligeramente si no hay input
            currentRotationSpeed -= (stateMachine.WhipSpinAcceleration * 0.3f) * deltaTime;
        }

        // Limitar velocidad
        currentRotationSpeed = Mathf.Clamp(currentRotationSpeed, stateMachine.WhipStartSpinSpeed, stateMachine.WhipMaxSpinSpeed);

        // Actualizar ángulo
        spinAngle += currentRotationSpeed * deltaTime;
        if (spinAngle >= 360f) spinAngle -= 360f;

        // Calcular posición en círculo
        float angleRad = spinAngle * Mathf.Deg2Rad;

        Vector3 offset = new Vector3(
            Mathf.Cos(angleRad) * stateMachine.WhipHoldRadius,
            0f,
            Mathf.Sin(angleRad) * stateMachine.WhipHoldRadius
        );

        // Rotar el offset según la orientación del jugador
        offset = stateMachine.transform.TransformDirection(offset);

        // Posición final del enemigo
        Vector3 enemyPosition = stateMachine.transform.position + Vector3.up * stateMachine.WhipHoldHeight + offset;

        capturedEnemy.position = enemyPosition;

        // Rotar al jugador basado en el input
        RotatePlayerWithInput(deltaTime);
    }

    private void RotatePlayerWithInput(float deltaTime)
    {
        Vector2 input = stateMachine.InputReader.MoveVector;

        if (input.magnitude < 0.1f) return;

        Vector3 cameraForward = Camera.main.transform.forward;
        Vector3 cameraRight = Camera.main.transform.right;
        cameraForward.y = 0;
        cameraRight.y = 0;
        cameraForward.Normalize();
        cameraRight.Normalize();

        Vector3 moveDirection = (cameraForward * input.y + cameraRight * input.x).normalized;

        if (moveDirection.sqrMagnitude > 0.01f)
        {
            Quaternion targetRotation = Quaternion.LookRotation(moveDirection);
            stateMachine.transform.rotation = Quaternion.Slerp(
                stateMachine.transform.rotation,
                targetRotation,
                stateMachine.RotationSpeed * deltaTime
            );
        }
    }

    #endregion

    #region Release & Throw

    private void OnRelease()
    {
        if (!isHolding) return;

        ThrowEnemy();
    }

    private void ThrowEnemy()
    {
        if (capturedEnemy == null) return;

        Debug.Log($"Lanzando enemigo con velocidad de giro: {currentRotationSpeed}");

        // Hacer el enemigo físico de nuevo
        if (capturedEnemyRb != null)
        {
            capturedEnemyRb.isKinematic = false;

            // Calcular dirección de lanzamiento (hacia donde mira el jugador)
            Vector3 throwDirection = stateMachine.transform.forward;

            // Fuerza basada en la velocidad de giro
            float throwForce = Mathf.Lerp(
                stateMachine.WhipThrowForceMin,
                stateMachine.WhipThrowForceMax,
                (currentRotationSpeed - stateMachine.WhipStartSpinSpeed) / (stateMachine.WhipMaxSpinSpeed - stateMachine.WhipStartSpinSpeed)
            );

            // Aplicar fuerza
            capturedEnemyRb.linearVelocity = Vector3.zero; // Reset velocidad
            capturedEnemyRb.AddForce(throwDirection * throwForce, ForceMode.Impulse);

            // Añadir spin para efecto visual
            capturedEnemyRb.AddTorque(Vector3.up * currentRotationSpeed * 0.1f, ForceMode.Impulse);
        }

        // Dejar de aturdir
        if (capturedEnemyScript != null)
        {
            capturedEnemyScript.Stun(false);
        }

        // Limpiar referencias
        capturedEnemy = null;
        capturedEnemyRb = null;
        capturedEnemyScript = null;
        isHolding = false;

        // Volver al estado normal
        stateMachine.SwitchState(typeof(PlayerFreeLookState));
    }

    private void ReleaseEnemy()
    {
        if (capturedEnemy == null) return;

        // Soltar sin lanzar (por si sale del estado)
        if (capturedEnemyRb != null)
        {
            capturedEnemyRb.isKinematic = false;
        }

        if (capturedEnemyScript != null)
        {
            capturedEnemyScript.Stun(false);
        }

        capturedEnemy = null;
        capturedEnemyRb = null;
        capturedEnemyScript = null;
    }

    #endregion

    #region Visuals

    private void UpdateRopeVisual()
    {
        if (stateMachine.GrappleRope == null || capturedEnemy == null) return;

        Vector3 startPoint = stateMachine.GrappleRopeOrigin != null
            ? stateMachine.GrappleRopeOrigin.position
            : stateMachine.transform.position + Vector3.up * 1.5f;

        stateMachine.GrappleRope.SetPosition(0, startPoint);
        stateMachine.GrappleRope.SetPosition(1, capturedEnemy.position);
    }

    #endregion
}