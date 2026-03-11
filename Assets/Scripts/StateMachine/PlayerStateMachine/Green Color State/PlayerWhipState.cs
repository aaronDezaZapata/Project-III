using UnityEngine;
using UnityEngine.AI;

public class PlayerWhipState : PlayerBaseState
{
    private enum WhipMode { None, EnemyWhip, GrappleSwing }
    private WhipMode currentMode = WhipMode.None;

    #region Animation Variables

    private readonly int FrontLianaAnim = Animator.StringToHash("FrontLiana");
    private const float CrossFadeDuration = 0.1f;

    #endregion

    #region Enemy Whip Variables
    private Transform capturedEnemy;
    private EnemyStateMachine capturedEnemyStateMachine;

    private float currentSpinSpeed;
    private float currentAngle;
    private bool isCapturing;
    private float captureProgress;
    private Vector3 captureStartPosition;
    #endregion

    #region Grapple Swing Variables
    private GrapplePoint currentGrapplePoint;
    private Vector3 grapplePosition;

    private float swingCurrentAngle;
    private float angularVelocity;
    private Vector3 swingPlaneNormal;
    private bool isAttached;

    private const float Gravity = 9.81f;
    private const float Damping = 1.0f;
    private const float EnergyBoost = 0.2f;
    private const float MinAngularVelocity = 1.5f;
    #endregion

    public PlayerWhipState(PlayerStateMachine stateMachine) : base(stateMachine) { }

    public override void Enter()
    {
        stateMachine.mainCamera.Priority = 10;

        if (TryFindAndCaptureEnemy())
        {
            currentMode = WhipMode.EnemyWhip;
            StartEnemyWhipMode();
        }
        else if (TryFindGrapplePoint())
        {
            currentMode = WhipMode.GrappleSwing;
            StartGrappleSwingMode();
        }
        else
        {
            // Sin objetivos: bloquear re-entrada mientras el botón siga pulsado
            stateMachine.WhipFailedLastAttempt = true;
            stateMachine.SwitchState(typeof(PlayerGreenState));
            return;
        }

        if (stateMachine.GrappleRope != null)
            stateMachine.GrappleRope.enabled = true;

        stateMachine.InputReader.JumpEvent += OnJump;
    }

    public override void Tick(float deltaTime)
    {
        if (!stateMachine.InputReader.isColorActing)
        {
            ExitWhipState();
            return;
        }

        switch (currentMode)
        {
            case WhipMode.EnemyWhip:    TickEnemyWhip(deltaTime);    break;
            case WhipMode.GrappleSwing: TickGrappleSwing(deltaTime); break;
        }

        UpdateRopeVisual();
    }

    public override void Exit()
    {
        stateMachine.InputReader.JumpEvent -= OnJump;

        if (stateMachine.GrappleRope != null)
            stateMachine.GrappleRope.enabled = false;

        switch (currentMode)
        {
            case WhipMode.EnemyWhip:    ExitEnemyWhip();    break;
            case WhipMode.GrappleSwing: ExitGrappleSwing(); break;
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
        if (capturedEnemy == null || capturedEnemyStateMachine == null)
        {
            stateMachine.SwitchState(typeof(PlayerGreenState));
            return;
        }

        if (isCapturing)
            HandleEnemyCapture(deltaTime);
        else
            HandleEnemyOrbit(deltaTime);

        // Movimiento reducido del jugador durante el látigo
        Vector3 movement = stateMachine.CalculateMovement();
        Move(movement * stateMachine.FreeLookMovementSpeed * 0.5f, deltaTime);

        if (movement.magnitude > 0.1f)
            FaceMovementDirection(movement, deltaTime);
    }

    private bool TryFindAndCaptureEnemy()
    {
        Collider[] hits = Physics.OverlapSphere(
            stateMachine.transform.position,
            stateMachine.EnemyDetectionRange,
            stateMachine.EnemyLayer
        );

        if (hits.Length == 0) return false;

        EnemyStateMachine closest = null;
        float closestDist = float.MaxValue;

        foreach (Collider col in hits)
        {
            // El collider pertenece al objeto raíz; EnemyStateMachine está en un hijo
            EnemyStateMachine esm = col.GetComponentInChildren<EnemyStateMachine>();
            if (esm == null) continue;

            Vector3 dirToEnemy = col.transform.position - stateMachine.transform.position;
            float dist = dirToEnemy.magnitude;

            // Comprobar línea de visión: ignorar si hay un obstáculo entre medias
            if (Physics.Raycast(stateMachine.transform.position + Vector3.up, dirToEnemy.normalized, out RaycastHit hit, dist))
            {
                EnemyStateMachine hitEsm = hit.collider.GetComponentInChildren<EnemyStateMachine>()
                                        ?? hit.collider.GetComponentInParent<EnemyStateMachine>();
                if (hitEsm != esm) continue;
            }

            if (dist < closestDist)
            {
                closestDist = dist;
                closest = esm;
            }
        }

        if (closest == null) return false;

        capturedEnemyStateMachine = closest;
        capturedEnemy = closest.transform;
        captureStartPosition = capturedEnemy.position;

        // Delegar desactivación de físicas al propio enemigo
        capturedEnemyStateMachine.DisablePhysics();
        capturedEnemyStateMachine.SwitchState(typeof(EnemyStunnedState));
        return true;
    }

    private void HandleEnemyCapture(float deltaTime)
    {
        captureProgress += deltaTime * stateMachine.WhipCaptureSpeed;

        if (captureProgress >= 1f)
        {
            captureProgress = 1f;
            isCapturing = false;
        }

        Vector3 playerPos = stateMachine.transform.position;
        Vector3 dirToPlayer = playerPos - captureStartPosition;
        dirToPlayer.y = 0;

        if (dirToPlayer.magnitude > 0.1f)
            dirToPlayer.Normalize();
        else
            dirToPlayer = stateMachine.transform.forward;

        Vector3 targetOrbitPos = playerPos
            + dirToPlayer * stateMachine.WhipHoldRadius
            + Vector3.up * stateMachine.WhipHoldHeight;

        capturedEnemy.position = Vector3.Lerp(captureStartPosition, targetOrbitPos, captureProgress);

        Vector3 lookDir = (capturedEnemy.position - playerPos).normalized;
        if (lookDir.magnitude > 0.1f)
            capturedEnemy.rotation = Quaternion.LookRotation(lookDir);
    }

    private void HandleEnemyOrbit(float deltaTime)
    {
        ApplySpinInput(deltaTime);

        currentAngle += currentSpinSpeed * deltaTime;
        if (currentAngle >= 360f) currentAngle -= 360f;

        Vector3 playerPos = stateMachine.transform.position;
        float angleRad = currentAngle * Mathf.Deg2Rad;

        Vector3 offset = new Vector3(
            Mathf.Cos(angleRad) * stateMachine.WhipHoldRadius,
            stateMachine.WhipHoldHeight,
            Mathf.Sin(angleRad) * stateMachine.WhipHoldRadius
        );

        capturedEnemy.position = playerPos + offset;

        Vector3 tangent = new Vector3(-Mathf.Sin(angleRad), 0, Mathf.Cos(angleRad));
        if (tangent.magnitude > 0.1f)
            capturedEnemy.rotation = Quaternion.LookRotation(tangent);
    }

    private void ApplySpinInput(float deltaTime)
    {
        if (stateMachine.InputReader.MoveVector.magnitude > 0.1f)
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

        Vector3 throwDir = Camera.main.transform.forward;
        float spinRatio = Mathf.InverseLerp(stateMachine.WhipStartSpinSpeed, stateMachine.WhipMaxSpinSpeed, currentSpinSpeed);
        float throwForce = Mathf.Lerp(stateMachine.WhipThrowForceMin, stateMachine.WhipThrowForceMax, spinRatio);

        capturedEnemyStateMachine.MarkAsThrown(throwForce);

        // Restaurar físicas antes de aplicar la fuerza de lanzamiento
        capturedEnemyStateMachine.RestorePhysics();

        if (capturedEnemyStateMachine.ForceReceiver != null)
        {
            capturedEnemyStateMachine.ForceReceiver.Reset();
            capturedEnemyStateMachine.ForceReceiver.AddForce(throwDir * throwForce);
        }

        ThrownEnemyController thrownController = capturedEnemy.gameObject.AddComponent<ThrownEnemyController>();
        thrownController.Initialize(
            throwDir * throwForce,
            capturedEnemyStateMachine.Controller,
            capturedEnemyStateMachine.ForceReceiver,
            capturedEnemyStateMachine
        );

        capturedEnemyStateMachine.SwitchState(typeof(EnemyStunnedState));

        capturedEnemy = null;
        capturedEnemyStateMachine = null;
    }

    private void ExitEnemyWhip()
    {
        if (capturedEnemy != null)
            ThrowEnemy();
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
        MovePlayer(deltaTime);
        RotatePlayer(deltaTime);
        CheckRopeIntegrity();
        AnimationGrapple();
    }

    private void AnimationGrapple()
    {
        stateMachine.Animator.CrossFadeInFixedTime(FrontLianaAnim, CrossFadeDuration);
    }

    private bool TryFindGrapplePoint()
    {
        GrapplePoint[] allPoints = Object.FindObjectsByType<GrapplePoint>(FindObjectsSortMode.None);
        GrapplePoint closest = null;
        float closestDist = float.MaxValue;
        Vector3 playerPos = stateMachine.transform.position;

        foreach (var point in allPoints)
        {
            if (!point.IsActive) continue;

            float dist = Vector3.Distance(playerPos, point.Position);
            if (dist > stateMachine.MaxGrappleDistance) continue;
            if (IsPathBlocked(playerPos, point.Position)) continue;

            if (dist < closestDist)
            {
                closestDist = dist;
                closest = point;
            }
        }

        if (closest == null) return false;

        currentGrapplePoint = closest;
        grapplePosition = closest.Position;
        return true;
    }

    private bool IsPathBlocked(Vector3 from, Vector3 to)
    {
        Vector3 dir = to - from;
        if (Physics.Raycast(from, dir.normalized, out RaycastHit hit, dir.magnitude, stateMachine.GrappleObstacleLayer))
            return hit.transform.GetComponent<GrapplePoint>() == null;

        return false;
    }

    private void AttachToGrapplePoint()
    {
        isAttached = true;

        Vector3 toGrapple = grapplePosition - stateMachine.transform.position;

        // Si estamos demasiado cerca, empujar al jugador al radio mínimo
        if (toGrapple.magnitude < stateMachine.SwingRadius)
        {
            stateMachine.transform.position = grapplePosition - toGrapple.normalized * stateMachine.SwingRadius;
            toGrapple = grapplePosition - stateMachine.transform.position;
        }

        Vector3 ropeVector = stateMachine.transform.position - grapplePosition;
        Vector3 currentVelocity = stateMachine.Controller.velocity;
        Vector3 swingDir = currentVelocity.magnitude > 0.5f ? currentVelocity : Camera.main.transform.forward;
        swingDir.y = 0;
        swingDir.Normalize();

        swingPlaneNormal = Vector3.Cross(Vector3.up, swingDir).normalized;
        if (swingPlaneNormal.magnitude < 0.1f)
        {
            swingPlaneNormal = Camera.main.transform.right;
            swingPlaneNormal.y = 0;
            swingPlaneNormal.Normalize();
        }

        float verticalDist = Mathf.Abs(grapplePosition.y - stateMachine.transform.position.y);
        swingCurrentAngle = Mathf.Acos(Mathf.Clamp(verticalDist / stateMachine.SwingRadius, -1f, 1f));

        Vector3 horizontalOffset = stateMachine.transform.position - grapplePosition;
        horizontalOffset.y = 0;
        if (Vector3.Dot(horizontalOffset, swingDir) < 0)
            swingCurrentAngle = -swingCurrentAngle;

        Vector3 tangentDir = Vector3.Cross(swingPlaneNormal, ropeVector).normalized;
        angularVelocity = Vector3.Dot(currentVelocity, tangentDir) / stateMachine.SwingRadius;

        if (Mathf.Abs(angularVelocity) < stateMachine.MinSwingSpeed)
        {
            float pushDir = Vector3.Dot(swingDir, tangentDir);
            angularVelocity = stateMachine.MinSwingSpeed * (Mathf.Abs(pushDir) > 0.1f ? Mathf.Sign(pushDir) : 1f);
        }
    }

    private void ApplyPendulumPhysics(float deltaTime)
    {
        float angularAcceleration = -(Gravity / stateMachine.SwingRadius) * Mathf.Sin(swingCurrentAngle);
        ApplySwingInput(ref angularAcceleration, deltaTime);
        
        if (Mathf.Abs(angularVelocity) > 0.5f)
        {
            angularAcceleration += EnergyBoost * Mathf.Sign(angularVelocity);
        }

        angularVelocity += angularAcceleration * deltaTime;
        angularVelocity *= (1f - 0.2f * deltaTime); // Amortiguación de aire
        swingCurrentAngle += angularVelocity * deltaTime;

        // Limitar ángulo suavemente para evitar loops completos
        if (Mathf.Abs(swingCurrentAngle) > Mathf.PI * 0.45f)
        {
            swingCurrentAngle = Mathf.Sign(swingCurrentAngle) * Mathf.PI * 0.45f;
            angularVelocity = -angularVelocity * 0.4f; // Rebote suave
        }
    }

    private void ApplySwingInput(ref float angularAcceleration, float deltaTime)
    {
        Vector2 input = stateMachine.InputReader.MoveVector;
        if (input.magnitude < 0.1f) return;

        Vector3 camForward = Camera.main.transform.forward;
        Vector3 camRight = Camera.main.transform.right;
        camForward.y = 0; camForward.Normalize();
        camRight.y = 0; camRight.Normalize();

        Vector3 inputDir = (camForward * input.y + camRight * input.x).normalized;
        Vector3 ropeVector = stateMachine.transform.position - grapplePosition;
        Vector3 tangentDir = Vector3.Cross(swingPlaneNormal, ropeVector).normalized;

        float alignment = Vector3.Dot(inputDir, tangentDir);
        
        if (Mathf.Abs(alignment) > 0.1f)
        {
             // Si el input empuja hacia donde ya nos movemos aplicamos toda la fuerza
             bool assistsMotion = (alignment > 0 && angularVelocity >= -0.1f) || (alignment < 0 && angularVelocity <= 0.1f);
             float forceMultiplier = assistsMotion ? 1f : 0.4f;
             
             angularAcceleration += alignment * stateMachine.SwingInputForce * forceMultiplier;
        }

        // Permitir al jugador controlar la dirección del balanceo
        Vector3 idealSwingPlaneNormal = Vector3.Cross(Vector3.up, inputDir).normalized;
        if (idealSwingPlaneNormal.sqrMagnitude > 0.01f)
        {
            if (Vector3.Dot(swingPlaneNormal, idealSwingPlaneNormal) < 0)
                idealSwingPlaneNormal = -idealSwingPlaneNormal;
                
            // rotar el plano en la parte baja del péndulo (Cos = 1)
            // En los extremos del arco (Cos = 0) apenas se rota para evitar que parezcan frenazos
            float turnFactor = Mathf.Max(0.1f, Mathf.Cos(swingCurrentAngle));
            float turnSpeed = stateMachine.RotationSpeed * turnFactor * 1.5f;

            swingPlaneNormal = Vector3.Slerp(swingPlaneNormal, idealSwingPlaneNormal, deltaTime * turnSpeed).normalized;
        }
    }

    private void MovePlayer(float deltaTime)
    {
        float radius = stateMachine.SwingRadius;
        Vector3 targetPos = grapplePosition
            + Vector3.up * (-radius * Mathf.Cos(swingCurrentAngle))
            + Vector3.Cross(Vector3.up, swingPlaneNormal).normalized * (radius * Mathf.Sin(swingCurrentAngle));

        stateMachine.Controller.Move(targetPos - stateMachine.transform.position);
    }

    private void RotatePlayer(float deltaTime)
    {
        Vector3 ropeVector = stateMachine.transform.position - grapplePosition;
        Vector3 moveDir = Vector3.Cross(swingPlaneNormal, ropeVector).normalized;
        
        // Determinar lado de la liana estamos usando frente al movimiento real
        if (angularVelocity < 0) moveDir = -moveDir;

        if (moveDir.sqrMagnitude > 0.01f && Mathf.Abs(angularVelocity) > 0.1f)
        {
           
            float dynamicRotationSpeed = stateMachine.RotationSpeed * Mathf.Clamp01(Mathf.Abs(angularVelocity));
            
            stateMachine.transform.rotation = Quaternion.Slerp(
                stateMachine.transform.rotation,
                Quaternion.LookRotation(moveDir),
                dynamicRotationSpeed * 2f * deltaTime
            );
        }
    }

    private void CheckRopeIntegrity()
    {
        if (Vector3.Distance(stateMachine.transform.position, grapplePosition) > stateMachine.MaxGrappleDistance * 1.2f)
            stateMachine.SwitchState(typeof(PlayerGreenState));
    }

    private void ApplySwingMomentum()
    {
        Vector3 ropeVector = stateMachine.transform.position - grapplePosition;
        Vector3 momentumDir = Vector3.Cross(swingPlaneNormal, ropeVector).normalized;
        Vector3 momentum = momentumDir * (angularVelocity * stateMachine.SwingRadius) + Vector3.up * stateMachine.GrappleJumpForce;
        stateMachine.ForceReceiver.AddForce(momentum);
    }

    private void ExitGrappleSwing()
    {
        float currentY = stateMachine.transform.eulerAngles.y;
        stateMachine.transform.rotation = Quaternion.Euler(0f, currentY, 0f);
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

        Vector3 start = stateMachine.GrappleRopeOrigin != null
            ? stateMachine.GrappleRopeOrigin.position
            : stateMachine.transform.position + Vector3.up * 1.5f;

        Vector3 end = currentMode == WhipMode.EnemyWhip && capturedEnemy != null
            ? capturedEnemy.position
            : grapplePosition;

        stateMachine.GrappleRope.SetPosition(0, start);
        stateMachine.GrappleRope.SetPosition(1, end);
    }

    private void FaceMovementDirection(Vector3 movement, float deltaTime)
    {
        stateMachine.transform.rotation = Quaternion.Lerp(
            stateMachine.transform.rotation,
            Quaternion.LookRotation(movement),
            deltaTime * stateMachine.RotationSpeed * 0.5f
        );
    }

    private void ExitWhipState()
    {
        bool wasGrapple = (currentMode == WhipMode.GrappleSwing);

        if (currentMode == WhipMode.EnemyWhip)
            ThrowEnemy();

        stateMachine.SwitchState(typeof(PlayerGreenState));
        
        if (wasGrapple)
        {
            if (stateMachine.GetCurrentState() is PlayerBaseState baseState)
            {
                baseState.ResetDoubleJump();
            }
        }
    }

    private void OnJump()
    {
        if (currentMode == WhipMode.GrappleSwing)
        {
            stateMachine.WhipFailedLastAttempt = true; // prevent automatic re-attach on jump
        }
        ExitWhipState();
    }

    #endregion
}

// Componente temporal que mueve al enemigo lanzado hasta que se detiene o expira
public class ThrownEnemyController : MonoBehaviour
{
    private Vector3 velocity;
    private CharacterController controller;
    private ForceReceiver forceReceiver;
    private EnemyStateMachine enemyStateMachine;
    private float elapsed = 0f;
    private const float Lifetime = 5f;
    private const float Gravity = 9.81f;
    private const float StopThreshold = 1f;

    public void Initialize(Vector3 initialVelocity, CharacterController cc, ForceReceiver fr, EnemyStateMachine esm)
    {
        velocity = initialVelocity;
        controller = cc;
        forceReceiver = fr;
        enemyStateMachine = esm;

        if (forceReceiver != null)
        {
            forceReceiver.Reset();
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

        if (forceReceiver != null && forceReceiver.enabled)
        {
            velocity = forceReceiver.Movement;
            controller.Move(velocity * Time.deltaTime);
        }
        else
        {
            // Fallback con gravedad manual si no hay ForceReceiver
            velocity.y -= Gravity * Time.deltaTime;
            controller.Move(velocity * Time.deltaTime);
        }

        if (enemyStateMachine != null)
            enemyStateMachine.thrownVelocityMagnitude = velocity.magnitude;

        if (controller.isGrounded && velocity.magnitude < StopThreshold)
        {
            Cleanup();
            return;
        }

        elapsed += Time.deltaTime;
        if (elapsed >= Lifetime)
            Cleanup();
    }

    private void Cleanup()
    {
        enemyStateMachine?.UnmarkAsThrown();
        Destroy(this);
    }
}
