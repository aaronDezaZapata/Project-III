using UnityEngine;

public class PlayerWhipState : PlayerBaseState
{
    #region Variables

    private enum WhipMode { None, ObjectWhip, GrappleSwing }
    private WhipMode currentMode = WhipMode.None;
    
    private readonly int IsOnWhipGrab = Animator.StringToHash("IsOnWhipGrab");
    
    private Transform capturedObject;
    private Rigidbody capturedRigidbody;

    private float currentSpinSpeed;
    private float currentAngle;
    private bool isCapturing;
    private float captureProgress;
    private Vector3 captureStartPosition;
    
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

    // Audio
    private bool spinAudioStarted;
    private bool swingLoopAudioStarted;

    public PlayerWhipState(PlayerStateMachine stateMachine) : base(stateMachine) { }

    public override void Enter()
    {
        stateMachine.MainCamera.Priority = 10;
        spinAudioStarted = false;
        swingLoopAudioStarted = false;

        if (TryFindAndCaptureObject())
        {
            currentMode = WhipMode.ObjectWhip;
            StartObjectWhipMode();
            stateMachine.PlayerAudio?.PlayObjectGrab();
        }
        else if (TryFindGrapplePoint())
        {
            currentMode = WhipMode.GrappleSwing;
            stateMachine.PlayerAudio?.PlayWhipThrow();
            StartGrappleSwingMode();
        }
        else
        {
            stateMachine.WhipFailedLastAttempt = true;
            stateMachine.SwitchState(typeof(PlayerGreenState));
            return;
        }

        stateMachine.UseColor(0.5f);

        if (stateMachine.GrappleRope != null)
            stateMachine.GrappleRope.enabled = true;


        stateMachine.InputReader.JumpEvent += OnJump;
        stateMachine.InputReader.ColorActionEvent += OnColorActionToggle;
    }

    public override void Tick(float deltaTime)
    {
        switch (currentMode)
        {
            case WhipMode.ObjectWhip:    TickObjectWhip(deltaTime);    break;
            case WhipMode.GrappleSwing: TickGrappleSwing(deltaTime); break;
        }

        UpdateRopeVisual();
    }

    public override void Exit()
    {
        stateMachine.InputReader.JumpEvent -= OnJump;
        stateMachine.InputReader.ColorActionEvent -= OnColorActionToggle;

        if (stateMachine.GrappleRope != null)
            stateMachine.GrappleRope.enabled = false;

        stateMachine.PlayerAudio?.StopObjectSpin();
        stateMachine.PlayerAudio?.StopWhipSwing();

        spinAudioStarted = false;
        swingLoopAudioStarted = false;

        switch (currentMode)
        {
            case WhipMode.ObjectWhip: ExitObjectWhip(); break;
            case WhipMode.GrappleSwing: ExitGrappleSwing(); break;
        }

        currentMode = WhipMode.None;
    }

    #region Object Whip Mode

    private void StartObjectWhipMode()
    {
        currentSpinSpeed = stateMachine.WhipStartSpinSpeed;
        currentAngle = 0f;
        isCapturing = true;
        captureProgress = 0f;
    }

    private void TickObjectWhip(float deltaTime)
    {
        if (capturedObject == null || capturedRigidbody == null)
        {
            stateMachine.SwitchState(typeof(PlayerGreenState));
            return;
        }

        if (isCapturing)
            HandleObjectCapture(deltaTime);
        else
            HandleObjectOrbit(deltaTime);
        
        Vector3 movement = stateMachine.CalculateMovement();
        Move(movement * stateMachine.FreeLookMovementSpeed * 0.5f, deltaTime);

        if (movement.magnitude > 0.1f)
            FaceMovementDirection(movement, deltaTime);
    }

    private bool TryFindAndCaptureObject()
    {
        Collider[] hits = Physics.OverlapSphere(
            stateMachine.transform.position,
            stateMachine.WhipObjectDetectionRange,
            stateMachine.WhipObjectLayer
        );

        if (hits.Length == 0) return false;

        Rigidbody closest = null;
        float closestDist = float.MaxValue;

        foreach (Collider col in hits)
        {
            Rigidbody rb = col.attachedRigidbody;
            if (rb == null) continue;
            
            if (rb.transform == stateMachine.transform || rb.transform.IsChildOf(stateMachine.transform)) continue;

            Vector3 dirToObject = col.transform.position - stateMachine.transform.position;
            float dist = dirToObject.magnitude;
            
            if (Physics.Raycast(stateMachine.transform.position + Vector3.up, dirToObject.normalized, out RaycastHit hit, dist))
            {
                Rigidbody hitRb = hit.collider.attachedRigidbody;
                if (hitRb != rb) continue;
            }

            if (dist < closestDist)
            {
                closestDist = dist;
                closest = rb;
            }
        }

        if (closest == null) return false;

        capturedRigidbody = closest;
        capturedObject = closest.transform;
        captureStartPosition = capturedObject.position;
        
        capturedRigidbody.isKinematic = true;
        capturedRigidbody.useGravity = false;
        
        return true;
    }

    private void HandleObjectCapture(float deltaTime)
    {
        captureProgress += deltaTime * stateMachine.WhipCaptureSpeed;

        if (captureProgress >= 1f)
        {
            captureProgress = 1f;
            isCapturing = false;

            //Audio
            if (!spinAudioStarted)
            {
                stateMachine.PlayerAudio?.StartObjectSpin();
                spinAudioStarted = true;
            }
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

        capturedObject.position = Vector3.Lerp(captureStartPosition, targetOrbitPos, captureProgress);

        Vector3 lookDir = (capturedObject.position - playerPos).normalized;
        if (lookDir.magnitude > 0.1f)
            capturedObject.rotation = Quaternion.LookRotation(lookDir);
    }

    private void HandleObjectOrbit(float deltaTime)
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

        capturedObject.position = playerPos + offset;

        Vector3 tangent = new Vector3(-Mathf.Sin(angleRad), 0, Mathf.Cos(angleRad));
        if (tangent.magnitude > 0.1f)
            capturedObject.rotation = Quaternion.LookRotation(tangent);
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

    private void ThrowObject()
    {
        if (capturedObject == null || capturedRigidbody == null) return;

        Vector3 throwDir = Camera.main.transform.forward;
        float spinRatio = Mathf.InverseLerp(stateMachine.WhipStartSpinSpeed, stateMachine.WhipMaxSpinSpeed, currentSpinSpeed);
        float throwForce = Mathf.Lerp(stateMachine.WhipThrowForceMin, stateMachine.WhipThrowForceMax, spinRatio);

        // Restaurar físicas y aplicar la fuerza
        capturedRigidbody.isKinematic = false;
        capturedRigidbody.useGravity = true;

        capturedRigidbody.linearVelocity = Vector3.zero;
        capturedRigidbody.AddForce(throwDir * throwForce, ForceMode.Impulse);

        ThrownObjectImpact impactComponent = capturedObject.GetComponent<ThrownObjectImpact>();
        if (impactComponent == null)
            impactComponent = capturedObject.gameObject.AddComponent<ThrownObjectImpact>();

        impactComponent.Initialize(stateMachine.PlayerAudio, 4f);

        //Audio
        stateMachine.PlayerAudio?.StopObjectSpin();
        stateMachine.PlayerAudio?.PlayObjectThrow();
        spinAudioStarted = false;

        capturedObject = null;
        capturedRigidbody = null;
    }

    private void ExitObjectWhip()
    {
        if (capturedObject != null)
            ThrowObject();
    }

    #endregion

    #region Grapple Swing Mode

    private void StartGrappleSwingMode()
    {
        stateMachine.ForceReceiver.enabled = false;
        AttachToGrapplePoint();
        stateMachine.PlayerAudio?.PlayWhipAttach();
        
        stateMachine.Animator.SetBool(IsOnWhipGrab, true);
    }

    private void TickGrappleSwing(float deltaTime)
    {
        if (!isAttached) return;

        if (!swingLoopAudioStarted)
        {
            stateMachine.PlayerAudio?.StartWhipSwing();
            swingLoopAudioStarted = true;
        }

        ApplyPendulumPhysics(deltaTime);
        MovePlayer(deltaTime);
        RotatePlayer(deltaTime);
        CheckRopeIntegrity();
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
        angularVelocity *= (1f - 0.2f * deltaTime);
        swingCurrentAngle += angularVelocity * deltaTime;
        
        if (Mathf.Abs(swingCurrentAngle) > Mathf.PI * 0.45f)
        {
            swingCurrentAngle = Mathf.Sign(swingCurrentAngle) * Mathf.PI * 0.45f;
            angularVelocity = -angularVelocity * 0.4f;
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
             bool assistsMotion = (alignment > 0 && angularVelocity >= -0.1f) || (alignment < 0 && angularVelocity <= 0.1f);
             float forceMultiplier = assistsMotion ? 1f : 0.4f;
             
             angularAcceleration += alignment * stateMachine.SwingInputForce * forceMultiplier;
        }
        
        Vector3 idealSwingPlaneNormal = Vector3.Cross(Vector3.up, inputDir).normalized;
        if (idealSwingPlaneNormal.sqrMagnitude > 0.01f)
        {
            if (Vector3.Dot(swingPlaneNormal, idealSwingPlaneNormal) < 0)
                idealSwingPlaneNormal = -idealSwingPlaneNormal;
            
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

        stateMachine.PlayerAudio?.StopWhipSwing();
        stateMachine.PlayerAudio?.PlayWhipRelease();

        stateMachine.ForceReceiver.enabled = true;
        ApplySwingMomentum();
        isAttached = false;
        currentGrapplePoint = null;
        
        stateMachine.Animator.SetBool(IsOnWhipGrab, false);
    }

    #endregion

    #region Shared Methods

    private void UpdateRopeVisual()
    {
        if (stateMachine.GrappleRope == null) return;

        Vector3 start = stateMachine.GrappleRopeOrigin != null
            ? stateMachine.GrappleRopeOrigin.position
            : stateMachine.transform.position + Vector3.up * 1.5f;

        Vector3 end = currentMode == WhipMode.ObjectWhip && capturedObject != null
            ? capturedObject.position
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

        if (currentMode == WhipMode.ObjectWhip)
            ThrowObject();

        // Asegurarse de que CheckGrounded se ejecute antes del cambio de estado
        stateMachine.CheckGrounded();
        
        stateMachine.SwitchState(typeof(PlayerGreenState));
        
        if (wasGrapple)
        {
            if (stateMachine.GetCurrentState() is PlayerBaseState baseState)
            {
                baseState.ResetDoubleJump();
            }
        }
    }

    private void OnColorActionToggle()
    {
        ExitWhipState();
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
