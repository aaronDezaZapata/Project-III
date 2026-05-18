using UnityEngine;

public class PlayerWhipState : PlayerBaseState
{
    private readonly int _isOnWhipGrab = Animator.StringToHash("IsOnWhipGrab");

    private Vector3 _grapplePosition;
    private float _swingCurrentAngle;
    private float _angularVelocity;
    private Vector3 _swingPlaneNormal;
    private bool _isAttached;
    private bool _swingLoopAudioStarted;

    private const float Gravity = 9.81f;
    private const float EnergyBoost = 0.2f;

    public PlayerWhipState(PlayerStateMachine stateMachine) : base(stateMachine) { }

    public override void Enter()
    {
        stateMachine.MainCamera.Priority = 10;
        _swingLoopAudioStarted = false;

        if (!TryFindGrapplePoint())
        {
            stateMachine.WhipFailedLastAttempt = true;
            stateMachine.SwitchState(typeof(PlayerGreenState));
            return;
        }
        
        stateMachine.PlayerAudio?.PlayWhipThrow();
        StartGrappleSwingMode();
        stateMachine.UseColor(0.5f);

        if (stateMachine.GrappleRope != null)
            stateMachine.GrappleRope.enabled = true;

        stateMachine.InputReader.JumpEvent += OnJump;
        stateMachine.InputReader.ColorActionEvent += OnColorActionToggle;
    }

    public override void Tick(float deltaTime)
    {
        TickGrappleSwing(deltaTime);
        UpdateRopeVisual();
    }

    public override void Exit()
    {
        stateMachine.InputReader.JumpEvent -= OnJump;
        stateMachine.InputReader.ColorActionEvent -= OnColorActionToggle;

        if (stateMachine.GrappleRope != null)
            stateMachine.GrappleRope.enabled = false;
        
        ExitGrappleSwing();
    }

    #region Grapple Swing

    private void StartGrappleSwingMode()
    {
        stateMachine.ForceReceiver.enabled = false;
        AttachToGrapplePoint();
        stateMachine.PlayerAudio?.PlayWhipAttach();
        stateMachine.Animator.SetBool(_isOnWhipGrab, true);
    }

    private void TickGrappleSwing(float deltaTime)
    {
        if (!_isAttached) return;

        if (!_swingLoopAudioStarted)
        {
            stateMachine.PlayerAudio?.StartWhipSwing();
            _swingLoopAudioStarted = true;
        }

        ApplyPendulumPhysics(deltaTime);
        MovePlayer();
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

        _grapplePosition = closest.Position;
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
        _isAttached = true;

        Vector3 toGrapple = _grapplePosition - stateMachine.transform.position;

        if (toGrapple.magnitude < stateMachine.SwingRadius)
            stateMachine.transform.position = _grapplePosition - toGrapple.normalized * stateMachine.SwingRadius;

        Vector3 ropeVector = stateMachine.transform.position - _grapplePosition;
        Vector3 currentVelocity = stateMachine.Controller.velocity;
        Vector3 swingDir = currentVelocity.magnitude > 0.5f ? currentVelocity : Camera.main.transform.forward;
        swingDir.y = 0;
        swingDir.Normalize();

        _swingPlaneNormal = Vector3.Cross(Vector3.up, swingDir).normalized;
        if (_swingPlaneNormal.magnitude < 0.1f)
        {
            _swingPlaneNormal = Camera.main.transform.right;
            _swingPlaneNormal.y = 0;
            _swingPlaneNormal.Normalize();
        }

        float verticalDist = Mathf.Abs(_grapplePosition.y - stateMachine.transform.position.y);
        _swingCurrentAngle = Mathf.Acos(Mathf.Clamp(verticalDist / stateMachine.SwingRadius, -1f, 1f));

        Vector3 horizontalOffset = stateMachine.transform.position - _grapplePosition;
        horizontalOffset.y = 0;
        if (Vector3.Dot(horizontalOffset, swingDir) < 0)
            _swingCurrentAngle = -_swingCurrentAngle;

        Vector3 tangentDir = Vector3.Cross(_swingPlaneNormal, ropeVector).normalized;
        _angularVelocity = Vector3.Dot(currentVelocity, tangentDir) / stateMachine.SwingRadius;

        if (Mathf.Abs(_angularVelocity) < stateMachine.MinSwingSpeed)
        {
            float pushDir = Vector3.Dot(swingDir, tangentDir);
            _angularVelocity = stateMachine.MinSwingSpeed * (Mathf.Abs(pushDir) > 0.1f ? Mathf.Sign(pushDir) : 1f);
        }
    }

    private void ApplyPendulumPhysics(float deltaTime)
    {
        float angularAcceleration = -(Gravity / stateMachine.SwingRadius) * Mathf.Sin(_swingCurrentAngle);
        ApplySwingInput(ref angularAcceleration, deltaTime);

        if (Mathf.Abs(_angularVelocity) > 0.5f)
            angularAcceleration += EnergyBoost * Mathf.Sign(_angularVelocity);

        _angularVelocity += angularAcceleration * deltaTime;
        _angularVelocity *= (1f - 0.2f * deltaTime);
        _swingCurrentAngle += _angularVelocity * deltaTime;

        if (Mathf.Abs(_swingCurrentAngle) > Mathf.PI * 0.45f)
        {
            _swingCurrentAngle = Mathf.Sign(_swingCurrentAngle) * Mathf.PI * 0.45f;
            _angularVelocity = -_angularVelocity * 0.4f;
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
        Vector3 ropeVector = stateMachine.transform.position - _grapplePosition;
        Vector3 tangentDir = Vector3.Cross(_swingPlaneNormal, ropeVector).normalized;

        float alignment = Vector3.Dot(inputDir, tangentDir);

        if (Mathf.Abs(alignment) > 0.1f)
        {
            bool assistsMotion = (alignment > 0 && _angularVelocity >= -0.1f) || (alignment < 0 && _angularVelocity <= 0.1f);
            float forceMultiplier = assistsMotion ? 1f : 0.4f;
            angularAcceleration += alignment * stateMachine.SwingInputForce * forceMultiplier;
        }

        Vector3 idealSwingPlaneNormal = Vector3.Cross(Vector3.up, inputDir).normalized;
        if (idealSwingPlaneNormal.sqrMagnitude > 0.01f)
        {
            if (Vector3.Dot(_swingPlaneNormal, idealSwingPlaneNormal) < 0)
                idealSwingPlaneNormal = -idealSwingPlaneNormal;

            float turnFactor = Mathf.Max(0.1f, Mathf.Cos(_swingCurrentAngle));
            float turnSpeed = stateMachine.RotationSpeed * turnFactor * 1.5f;
            _swingPlaneNormal = Vector3.Slerp(_swingPlaneNormal, idealSwingPlaneNormal, deltaTime * turnSpeed).normalized;
        }
    }

    private void MovePlayer()
    {
        float radius = stateMachine.SwingRadius;
        Vector3 targetPos = _grapplePosition
            + Vector3.up * (-radius * Mathf.Cos(_swingCurrentAngle))
            + Vector3.Cross(Vector3.up, _swingPlaneNormal).normalized * (radius * Mathf.Sin(_swingCurrentAngle));

        stateMachine.Controller.Move(targetPos - stateMachine.transform.position);
    }

    private void RotatePlayer(float deltaTime)
    {
        Vector3 ropeVector = stateMachine.transform.position - _grapplePosition;
        Vector3 moveDir = Vector3.Cross(_swingPlaneNormal, ropeVector).normalized;

        if (_angularVelocity < 0) moveDir = -moveDir;

        if (moveDir.sqrMagnitude > 0.01f && Mathf.Abs(_angularVelocity) > 0.1f)
        {
            float dynamicRotationSpeed = stateMachine.RotationSpeed * Mathf.Clamp01(Mathf.Abs(_angularVelocity));
            stateMachine.transform.rotation = Quaternion.Slerp(
                stateMachine.transform.rotation,
                Quaternion.LookRotation(moveDir),
                dynamicRotationSpeed * 2f * deltaTime
            );
        }
    }

    private void CheckRopeIntegrity()
    {
        if (Vector3.Distance(stateMachine.transform.position, _grapplePosition) > stateMachine.MaxGrappleDistance * 1.2f)
            stateMachine.SwitchState(typeof(PlayerGreenState));
    }

    private void ApplySwingMomentum()
    {
        Vector3 ropeVector = stateMachine.transform.position - _grapplePosition;
        Vector3 momentumDir = Vector3.Cross(_swingPlaneNormal, ropeVector).normalized;
        Vector3 momentum = momentumDir * (_angularVelocity * stateMachine.SwingRadius) + Vector3.up * stateMachine.GrappleJumpForce;
        stateMachine.ForceReceiver.AddForce(momentum);
    }

    private void ExitGrappleSwing()
    {
        if (!_isAttached) return;

        float currentY = stateMachine.transform.eulerAngles.y;
        stateMachine.transform.rotation = Quaternion.Euler(0f, currentY, 0f);

        stateMachine.PlayerAudio?.StopWhipSwing();
        stateMachine.PlayerAudio?.PlayWhipRelease();

        stateMachine.ForceReceiver.enabled = true;
        ApplySwingMomentum();
        _isAttached = false;

        stateMachine.Animator.SetBool(_isOnWhipGrab, false);
    }

    #endregion

    private void UpdateRopeVisual()
    {
        if (stateMachine.GrappleRope == null) return;

        Vector3 start = stateMachine.GrappleRopeOrigin != null
            ? stateMachine.GrappleRopeOrigin.position
            : stateMachine.transform.position + Vector3.up * 1.5f;

        stateMachine.GrappleRope.SetPosition(0, start);
        stateMachine.GrappleRope.SetPosition(1, _grapplePosition);
    }

    private void ExitWhipState()
    {
        stateMachine.CheckGrounded();
        stateMachine.SwitchState(typeof(PlayerGreenState));

        if (stateMachine.GetCurrentState() is PlayerBaseState baseState)
            baseState.ResetDoubleJump();
    }

    private void OnColorActionToggle()
    {
        ExitWhipState();
    }

    private void OnJump()
    {
        stateMachine.WhipFailedLastAttempt = true;
        ExitWhipState();
    }
}
