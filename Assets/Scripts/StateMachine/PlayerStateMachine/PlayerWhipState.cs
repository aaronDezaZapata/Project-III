using UnityEngine;
using UnityEngine.AI;

/// <summary>
/// Estado que maneja la habilidad Verde:
/// 1. PRIORIDAD: Enemigos cercanos → Látigo (capturar, girar, lanzar)
/// 2. SECUNDARIO: GrapplePoints → Balanceo (péndulo)
/// 3. Nada encontrado → Volver a PlayerGreenState
/// </summary>
public class PlayerWhipState : PlayerBaseState
{
    // Modo del estado
    private enum WhipMode
    {
        None,
        EnemyWhip,    // Látigo con enemigos
        GrappleSwing  // Balanceo con GrapplePoint
    }

    private WhipMode currentMode = WhipMode.None;

    #region Enemy Whip Variables
    private Transform capturedEnemy;
    private EnemyStateMachine capturedEnemyStateMachine;
    
    // Componentes del enemigo
    private CharacterController enemyController;
    private ForceReceiver enemyForceReceiver;
    private NavMeshAgent enemyAgent;
    private Collider enemyCollider;
    
    // Estados originales del enemigo
    private bool originalControllerEnabled;
    private bool originalAgentEnabled;
    private bool originalForceReceiverEnabled;
    
    // Variables de rotación del enemigo
    private float currentSpinSpeed;
    private float currentAngle;
    private bool isCapturing;
    private float captureProgress;
    private Vector3 captureStartPosition;
    #endregion

    #region Grapple Swing Variables
    private GrapplePoint currentGrapplePoint;
    private Vector3 grapplePosition;
    
    // Física del péndulo
    private float swingCurrentAngle;
    private float angularVelocity;
    private Vector3 swingPlaneNormal;
    private bool isAttached;
    
    // Constantes del péndulo
    private const float Gravity = 9.81f;
    private const float Damping = 1.0f;
    private const float EnergyBoost = 0.2f;
    private const float MinAngularVelocity = 1.5f;
    #endregion

    public PlayerWhipState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        Debug.Log("Entered PlayerWhipState - Checking for targets...");
        
        // Configurar cámara
        stateMachine.mainCamera.Priority = 10;
        
        // Buscar primero ENEMIGOS (prioridad)
        if (TryFindAndCaptureEnemy())
        {
            Debug.Log("Enemy found - Starting WHIP mode");
            currentMode = WhipMode.EnemyWhip;
            StartEnemyWhipMode();
        }
        // Si no hay enemigos, buscar GRAPPLE POINTS
        else if (TryFindGrapplePoint())
        {
            Debug.Log("GrapplePoint found - Starting SWING mode");
            currentMode = WhipMode.GrappleSwing;
            StartGrappleSwingMode();
        }
        // Si no hay nada, volver al estado base
        else
        {
            Debug.LogWarning("No enemies or GrapplePoints found - Returning to PlayerGreenState");
            stateMachine.SwitchState(typeof(PlayerGreenState));
            return;
        }
        
        // Activar rope visual
        if (stateMachine.GrappleRope != null)
        {
            stateMachine.GrappleRope.enabled = true;
        }
        
        // Suscribirse a eventos
        stateMachine.InputReader.JumpEvent += OnJump;
    }

    public override void Tick(float deltaTime)
    {
        // Si suelta el botón de color, salir
        if (!stateMachine.InputReader.isColorActing)
        {
            ExitWhipState();
            return;
        }
        
        // Ejecutar lógica según el modo actual
        switch (currentMode)
        {
            case WhipMode.EnemyWhip:
                TickEnemyWhip(deltaTime);
                break;
                
            case WhipMode.GrappleSwing:
                TickGrappleSwing(deltaTime);
                break;
        }
        
        // Actualizar visual de la cuerda
        UpdateRopeVisual();
    }

    public override void Exit()
    {
        Debug.Log("Exiting PlayerWhipState");
        
        // Desuscribirse de eventos
        stateMachine.InputReader.JumpEvent -= OnJump;
        
        // Ocultar rope
        if (stateMachine.GrappleRope != null)
        {
            stateMachine.GrappleRope.enabled = false;
        }
        
        // Limpiar según el modo
        switch (currentMode)
        {
            case WhipMode.EnemyWhip:
                ExitEnemyWhip();
                break;
                
            case WhipMode.GrappleSwing:
                ExitGrappleSwing();
                break;
        }
        
        currentMode = WhipMode.None;
    }

    #region Enemy Whip Mode

    private void StartEnemyWhipMode()
    {
        currentSpinSpeed = stateMachine.WhipStartSpinSpeed;
        currentAngle = 0f;
        isCapturing = true;
        captureProgress = 0f;
    }

    private void TickEnemyWhip(float deltaTime)
    {
        // Verificar que el enemigo sigue válido
        if (capturedEnemy == null || capturedEnemyStateMachine == null)
        {
            Debug.LogWarning("Enemy lost during whip");
            stateMachine.SwitchState(typeof(PlayerGreenState));
            return;
        }
        
        if (isCapturing)
        {
            HandleEnemyCapture(deltaTime);
        }
        else
        {
            HandleEnemyOrbit(deltaTime);
        }
        
        // Permitir movimiento reducido del jugador
        Vector3 movement = stateMachine.CalculateMovement();
        Move(movement * stateMachine.FreeLookMovementSpeed * 0.5f, deltaTime);
        
        if (movement.magnitude > 0.1f)
        {
            FaceMovementDirection(movement, deltaTime);
        }
    }

    private bool TryFindAndCaptureEnemy()
    {
        Collider[] enemies = Physics.OverlapSphere(
            stateMachine.transform.position,
            stateMachine.EnemyDetectionRange,
            stateMachine.EnemyLayer
        );
        
        if (enemies.Length == 0) return false;
        
        // Encontrar enemigo más cercano con línea de visión
        Transform closestEnemy = null;
        float closestDistance = float.MaxValue;
        
        foreach (Collider enemyCollider in enemies)
        {
            Vector3 dirToEnemy = enemyCollider.transform.position - stateMachine.transform.position;
            float distance = dirToEnemy.magnitude;
            
            // Verificar línea de visión
            int layerMask = ~stateMachine.EnemyLayer;
            if (!Physics.Raycast(
                stateMachine.transform.position + Vector3.up,
                dirToEnemy.normalized,
                distance,
                layerMask))
            {
                if (distance < closestDistance)
                {
                    closestDistance = distance;
                    closestEnemy = enemyCollider.transform;
                }
            }
        }
        
        if (closestEnemy == null) return false;
        
        // Capturar el enemigo
        capturedEnemy = closestEnemy;
        capturedEnemyStateMachine = closestEnemy.GetComponent<EnemyStateMachine>();
        
        if (capturedEnemyStateMachine == null)
        {
            Debug.LogError("Enemy doesn't have EnemyStateMachine!");
            return false;
        }
        
        captureStartPosition = capturedEnemy.position;
        DisableEnemyPhysics();
        capturedEnemyStateMachine.SwitchState(typeof(EnemyStunnedState));
        
        Debug.Log($"Enemy captured: {capturedEnemy.name}");
        return true;
    }

    private void DisableEnemyPhysics()
    {
        enemyController = capturedEnemy.GetComponent<CharacterController>();
        if (enemyController != null)
        {
            originalControllerEnabled = enemyController.enabled;
            enemyController.enabled = false;
        }
        
        enemyForceReceiver = capturedEnemy.GetComponent<ForceReceiver>();
        if (enemyForceReceiver != null)
        {
            originalForceReceiverEnabled = enemyForceReceiver.enabled;
            enemyForceReceiver.enabled = false;
        }
        
        enemyAgent = capturedEnemy.GetComponent<NavMeshAgent>();
        if (enemyAgent != null)
        {
            originalAgentEnabled = enemyAgent.enabled;
            enemyAgent.enabled = false;
        }
        
        enemyCollider = capturedEnemy.GetComponent<Collider>();
        
        Debug.Log("Enemy physics disabled");
    }

    private void RestoreEnemyPhysics()
    {
        if (capturedEnemy == null) return;
        
        if (enemyController != null)
        {
            enemyController.enabled = originalControllerEnabled;
        }
        
        if (enemyForceReceiver != null)
        {
            enemyForceReceiver.enabled = originalForceReceiverEnabled;
        }
        
        if (enemyAgent != null)
        {
            enemyAgent.enabled = originalAgentEnabled;
        }
        
        Debug.Log("Enemy physics restored");
    }

    private void HandleEnemyCapture(float deltaTime)
    {
        captureProgress += deltaTime * stateMachine.WhipCaptureSpeed;
        
        if (captureProgress >= 1f)
        {
            captureProgress = 1f;
            isCapturing = false;
            Debug.Log("Capture complete, starting orbit");
        }
        
        Vector3 playerPos = stateMachine.transform.position;
        Vector3 directionToPlayer = playerPos - captureStartPosition;
        directionToPlayer.y = 0;
        
        if (directionToPlayer.magnitude > 0.1f)
        {
            directionToPlayer.Normalize();
        }
        else
        {
            directionToPlayer = stateMachine.transform.forward;
        }
        
        Vector3 targetOrbitPosition = playerPos 
            + directionToPlayer * stateMachine.WhipHoldRadius 
            + Vector3.up * stateMachine.WhipHoldHeight;
        
        capturedEnemy.position = Vector3.Lerp(
            captureStartPosition,
            targetOrbitPosition,
            captureProgress
        );
        
        Vector3 lookDirection = (capturedEnemy.position - playerPos).normalized;
        if (lookDirection.magnitude > 0.1f)
        {
            capturedEnemy.rotation = Quaternion.LookRotation(lookDirection);
        }
    }

    private void HandleEnemyOrbit(float deltaTime)
    {
        // Aplicar input para acelerar
        ApplySpinInput(deltaTime);
        
        // Actualizar ángulo
        currentAngle += currentSpinSpeed * deltaTime;
        if (currentAngle >= 360f) currentAngle -= 360f;
        
        // Calcular posición orbital
        Vector3 playerPos = stateMachine.transform.position;
        float angleRad = currentAngle * Mathf.Deg2Rad;
        
        Vector3 offset = new Vector3(
            Mathf.Cos(angleRad) * stateMachine.WhipHoldRadius,
            stateMachine.WhipHoldHeight,
            Mathf.Sin(angleRad) * stateMachine.WhipHoldRadius
        );
        
        capturedEnemy.position = playerPos + offset;
        
        // Orientar enemigo tangencialmente
        Vector3 tangent = new Vector3(-Mathf.Sin(angleRad), 0, Mathf.Cos(angleRad));
        if (tangent.magnitude > 0.1f)
        {
            capturedEnemy.rotation = Quaternion.LookRotation(tangent);
        }
    }

    private void ApplySpinInput(float deltaTime)
    {
        Vector2 input = stateMachine.InputReader.MoveVector;
        
        if (input.magnitude > 0.1f)
        {
            currentSpinSpeed += stateMachine.WhipSpinAcceleration * deltaTime;
            currentSpinSpeed = Mathf.Min(currentSpinSpeed, stateMachine.WhipMaxSpinSpeed);
        }
        else
        {
            currentSpinSpeed = Mathf.Max(
                currentSpinSpeed - stateMachine.WhipSpinAcceleration * 0.5f * deltaTime,
                stateMachine.WhipStartSpinSpeed
            );
        }
    }

    private void ThrowEnemy()
    {
        if (capturedEnemy == null) return;
        
        Debug.Log("Throwing enemy...");
        
        // Dirección de lanzamiento (hacia la cámara)
        Vector3 throwDirection = Camera.main.transform.forward;
        
        // Calcular fuerza basada en velocidad de giro
        float spinRatio = Mathf.InverseLerp(
            stateMachine.WhipStartSpinSpeed,
            stateMachine.WhipMaxSpinSpeed,
            currentSpinSpeed
        );
        
        float throwForce = Mathf.Lerp(
            stateMachine.WhipThrowForceMin,
            stateMachine.WhipThrowForceMax,
            spinRatio
        );
        
        Vector3 throwVelocity = throwDirection * throwForce;
        
        Debug.Log($"Spin speed: {currentSpinSpeed}°/s, Force: {throwForce}, Direction: {throwDirection}");
        
        // Marcar enemigo como lanzado
        if (capturedEnemyStateMachine != null)
        {
            capturedEnemyStateMachine.MarkAsThrown(throwForce);
        }
        
        // Restaurar físicas
        RestoreEnemyPhysics();
        
        // Aplicar fuerza al ForceReceiver
        if (enemyForceReceiver != null)
        {
            enemyForceReceiver.Reset();
            enemyForceReceiver.AddForce(throwVelocity);
            Debug.Log("Force applied to enemy ForceReceiver");
        }
        
        // Añadir componente de tracking
        ThrownEnemyController thrownController = capturedEnemy.gameObject.AddComponent<ThrownEnemyController>();
        thrownController.Initialize(throwVelocity, enemyController, enemyForceReceiver, capturedEnemyStateMachine);
        
        // Cambiar estado del enemigo
        if (capturedEnemyStateMachine != null)
        {
            capturedEnemyStateMachine.SwitchState(typeof(EnemyStunnedState));
        }
        
        capturedEnemy = null;
        capturedEnemyStateMachine = null;
    }

    private void ExitEnemyWhip()
    {
        if (capturedEnemy != null)
        {
            ThrowEnemy();
        }
    }

    #endregion

    #region Grapple Swing Mode

    private void StartGrappleSwingMode()
    {
        stateMachine.ForceReceiver.enabled = false;
        AttachToGrapplePoint();
    }

    private void TickGrappleSwing(float deltaTime)
    {
        if (!isAttached) return;
        
        ApplyPendulumPhysics(deltaTime);
        MaintainMinimumEnergy();
        MovePlayer(deltaTime);
        RotatePlayer(deltaTime);
        CheckRopeIntegrity();
    }

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
        swingCurrentAngle = Mathf.Acos(Mathf.Clamp(verticalDistance / stateMachine.SwingRadius, -1f, 1f));
        
        Vector3 horizontalOffset = stateMachine.transform.position - grapplePosition;
        horizontalOffset.y = 0;
        
        float side = Vector3.Dot(horizontalOffset, swingDirection);
        if (side < 0)
        {
            swingCurrentAngle = -swingCurrentAngle;
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
        
        Debug.Log($"Attached to grapple - Angle: {swingCurrentAngle * Mathf.Rad2Deg}°, Angular velocity: {angularVelocity}");
    }

    private void ApplyPendulumPhysics(float deltaTime)
    {
        float angularAcceleration = -(Gravity / stateMachine.SwingRadius) * Mathf.Sin(swingCurrentAngle);
        
        ApplySwingInput(ref angularAcceleration, deltaTime);
        
        angularAcceleration += EnergyBoost * Mathf.Sign(angularVelocity);
        
        angularVelocity += angularAcceleration * deltaTime;
        angularVelocity *= Damping;
        
        swingCurrentAngle += angularVelocity * deltaTime;
        
        if (Mathf.Abs(swingCurrentAngle) > Mathf.PI * 0.5f)
        {
            swingCurrentAngle = Mathf.Sign(swingCurrentAngle) * Mathf.PI * 0.5f;
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

    private void ApplySwingInput(ref float angularAcceleration, float deltaTime)
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

    private void MovePlayer(float deltaTime)
    {
        float radius = stateMachine.SwingRadius;
        
        float verticalOffset = -radius * Mathf.Cos(swingCurrentAngle);
        float horizontalOffset = radius * Mathf.Sin(swingCurrentAngle);
        
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

    private void CheckRopeIntegrity()
    {
        float currentDistance = Vector3.Distance(stateMachine.transform.position, grapplePosition);
        
        if (currentDistance > stateMachine.MaxGrappleDistance * 1.2f)
        {
            Debug.Log("Rope broke - too far");
            stateMachine.SwitchState(typeof(PlayerGreenState));
        }
    }

    private void ApplySwingMomentum()
    {
        float linearSpeed = angularVelocity * stateMachine.SwingRadius;
        
        Vector3 ropeVector = stateMachine.transform.position - grapplePosition;
        Vector3 momentumDirection = Vector3.Cross(swingPlaneNormal, ropeVector).normalized;
        
        Vector3 momentum = momentumDirection * linearSpeed;
        momentum += Vector3.up * stateMachine.GrappleJumpForce;
        
        stateMachine.ForceReceiver.AddForce(momentum);
        
        Debug.Log($"Released with momentum: {momentum.magnitude:F2}");
    }

    private void ForcePlayerUpright()
    {
        float currentYRotation = stateMachine.transform.eulerAngles.y;
        stateMachine.transform.rotation = Quaternion.Euler(0f, currentYRotation, 0f);
    }

    private void ExitGrappleSwing()
    {
        ForcePlayerUpright();
        stateMachine.ForceReceiver.enabled = true;
        ApplySwingMomentum();
        isAttached = false;
        currentGrapplePoint = null;
    }

    #endregion

    #region Shared Methods

    private void UpdateRopeVisual()
    {
        if (stateMachine.GrappleRope == null) return;
        
        Vector3 startPoint = stateMachine.GrappleRopeOrigin != null
            ? stateMachine.GrappleRopeOrigin.position
            : stateMachine.transform.position + Vector3.up * 1.5f;
        
        Vector3 endPoint = Vector3.zero;
        
        switch (currentMode)
        {
            case WhipMode.EnemyWhip:
                if (capturedEnemy != null)
                {
                    endPoint = capturedEnemy.position;
                }
                break;
                
            case WhipMode.GrappleSwing:
                endPoint = grapplePosition;
                break;
        }
        
        stateMachine.GrappleRope.SetPosition(0, startPoint);
        stateMachine.GrappleRope.SetPosition(1, endPoint);
    }

    private void FaceMovementDirection(Vector3 movement, float deltaTime)
    {
        stateMachine.transform.rotation = Quaternion.Lerp(
            stateMachine.transform.rotation,
            Quaternion.LookRotation(movement),
            deltaTime * stateMachine.RotationSpeed * 0.5f);
    }

    private void ExitWhipState()
    {
        switch (currentMode)
        {
            case WhipMode.EnemyWhip:
                ThrowEnemy();
                break;
                
            case WhipMode.GrappleSwing:
                // No hacer nada, el Exit se encarga
                break;
        }
        
        stateMachine.SwitchState(typeof(PlayerGreenState));
    }

    private void OnJump()
    {
        ExitWhipState();
    }

    #endregion
}

/// <summary>
/// Componente para trackear enemigos lanzados con CharacterController + ForceReceiver
/// </summary>
public class ThrownEnemyController : MonoBehaviour
{
    private Vector3 velocity;
    private CharacterController controller;
    private ForceReceiver forceReceiver;
    private EnemyStateMachine enemyStateMachine;
    private float lifetime = 5f;
    private float elapsed = 0f;
    private const float gravity = 9.81f;
    private const float stoppedThreshold = 1f;
    
    public void Initialize(Vector3 initialVelocity, CharacterController characterController, 
                          ForceReceiver receiver, EnemyStateMachine enemyMachine)
    {
        velocity = initialVelocity;
        controller = characterController;
        forceReceiver = receiver;
        enemyStateMachine = enemyMachine;
        
        if (forceReceiver != null)
        {
            forceReceiver.Reset(); // Limpiar fuerzas previas
            forceReceiver.AddForce(initialVelocity);
        }
    }
    
    private void Update()
    {
        if (controller == null || !controller.enabled)
        {
            Cleanup();
            return;
        }
        
        // CRÍTICO: Aplicar el movimiento del ForceReceiver al CharacterController
        if (forceReceiver != null && forceReceiver.enabled)
        {
            // El ForceReceiver calcula el movimiento (gravedad + fuerzas)
            Vector3 movement = forceReceiver.Movement;
            
            // Aplicar el movimiento al CharacterController
            controller.Move(movement * Time.deltaTime);
            
            // Calcular velocidad actual para tracking
            velocity = movement;
        }
        else
        {
            // Fallback: aplicar gravedad manualmente si no hay ForceReceiver
            velocity.y -= gravity * Time.deltaTime;
            controller.Move(velocity * Time.deltaTime);
        }
        
        // Actualizar velocidad en EnemyStateMachine
        if (enemyStateMachine != null)
        {
            enemyStateMachine.thrownVelocityMagnitude = velocity.magnitude;
        }
        
        // Si toca suelo y va lento, detener
        if (controller.isGrounded && velocity.magnitude < stoppedThreshold)
        {
            Debug.Log("Thrown enemy stopped");
            Cleanup();
            return;
        }
        
        // Timeout
        elapsed += Time.deltaTime;
        if (elapsed >= lifetime)
        {
            Debug.Log("Throw time expired");
            Cleanup();
        }
    }
    
    private void Cleanup()
    {
        if (enemyStateMachine != null)
        {
            enemyStateMachine.UnmarkAsThrown();
        }
        
        Destroy(this);
    }
}
