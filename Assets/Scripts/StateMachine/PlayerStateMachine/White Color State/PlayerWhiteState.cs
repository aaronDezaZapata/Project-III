using Unity.Cinemachine;
using UnityEngine;

/// <summary>
/// Player White State (Default)
/// - Movement
/// - Jump
/// - Blend Trees
/// - Swim transition
/// </summary>
public class PlayerWhiteState : PlayerBaseState
{
    // Animation Hashes
    protected readonly int FreeLookSpeedHash = Animator.StringToHash("SpeedX");
    protected readonly int AnimationSpeedHash = Animator.StringToHash("AimSpeedX");
    protected readonly int VerticalSpeedHash = Animator.StringToHash("SpeedY");
    protected readonly int GroundedHash = Animator.StringToHash("IsGrounded");
    
    protected readonly int FreeLookBlendTreeHash = Animator.StringToHash("FreeLookBlendTree");
    protected readonly int WalkingBlendTreeHash = Animator.StringToHash("WalkingBlendTree");

    protected readonly int StopRun = Animator.StringToHash("StopRun");

    protected readonly int AnimJump = Animator.StringToHash("Impulse");

    // Constants
    protected const float CrossFadeDuration = 0.1f;
    protected const float AnimatorDampTime = 0.1f;

    protected const float RunThreshold = 0.7f;
    protected const float IdleThreshold = 0.05f;
    
    // State tracking
    protected float lastSpeed = 0f;
    protected float lastInputMagnitude = 0f;
    
    public PlayerWhiteState(PlayerStateMachine stateMachine) : base(stateMachine)
    { 
       
    }


    public override void Enter()
    {
        Debug.Log("Entered PlayerWhiteState");
        
        SetPlayerState();
        
        SetMaterialColor();
        
        SubscribeToInputEvents();
        
        SetupCamera();
        
        InitializeAnimator();
    }
    
    // Default player state
    // Overridden in other states
    protected virtual void SetPlayerState()
    {
        stateMachine.playerState = PlayerStates.WHITE;
    }
    
    // Initial material color config
    protected virtual void SetMaterialColor()
    {
        stateMachine.Mat_Player.material.SetColor("_SpecularColor", Color.white);
    }
    
    // Input events to subscribe
    protected virtual void SubscribeToInputEvents()
    {
        stateMachine.InputReader.JumpEvent += OnJump;
        stateMachine.InputReader.DiveEvent += OnDiveEnter;
    }
    
    // Default Camera Setup
    protected virtual void SetupCamera()
    {
        if (stateMachine.mainCamera.Priority <= 9)
        {
            CameraRecenter();
            stateMachine.mainCamera.Priority = 10;
        }
    }
    
    protected virtual void InitializeAnimator()
    {
        stateMachine.Animator.SetFloat(FreeLookSpeedHash, 0);
        stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
        lastSpeed = 0f;
        //lastInputMagnitude = 0f;
    }

    public override void Tick(float deltaTime)
    {
        stateMachine.CheckGrounded();
        
        // Check for color-specific actions - Los estados hijos pueden sobrescribir
        if (CheckColorSpecificActions(deltaTime))
        {
            return; // El estado hijo manejó la transición
        }

        // Calculate movement
        Vector3 movement = stateMachine.CalculateMovement();
        float currentInputMagnitude = movement.magnitude;

        // Update animator parameters
        UpdateAnimatorParameters(movement, currentInputMagnitude, deltaTime);

        // Handle blend tree transitions
        HandleBlendTreeTransition(currentInputMagnitude);
        
        // Face movement direction if running
        if (currentInputMagnitude > RunThreshold)
        {
            FaceMovementDirection(movement, deltaTime);
        }

        // Handle jump landing
        HandleJumpLanding(currentInputMagnitude);

        // Apply movement
        Move(movement * stateMachine.FreeLookMovementSpeed, deltaTime);

        // Update state tracking
        lastSpeed = currentInputMagnitude;
        lastInputMagnitude = currentInputMagnitude;
    }
    
    
    // TODO: Check
    // Color actions scheme changed.
    // Maybe this needs to be removed???
    // Actually can be and needs to be overrided
    protected virtual bool CheckColorSpecificActions(float deltaTime)
    {
        // White state: Dash Attack
        if (stateMachine.InputReader.isColorActing && stateMachine.HasDashAttack)
        {
            if (HasNearbyPaintedEnemy())
            {
                stateMachine.SwitchState(typeof(PlayerDashAttackState));
                return true;
            }
        }
        return false;
    }
    
    protected virtual void UpdateAnimatorParameters(Vector3 movement, float currentInputMagnitude, float deltaTime)
    {
        stateMachine.Animator.SetFloat(FreeLookSpeedHash, currentInputMagnitude, AnimatorDampTime, deltaTime);
        stateMachine.Animator.SetFloat(AnimationSpeedHash, movement.x, AnimatorDampTime, deltaTime);
        stateMachine.Animator.SetFloat(VerticalSpeedHash, stateMachine.Controller.velocity.y, AnimatorDampTime, deltaTime);
        stateMachine.Animator.SetBool(GroundedHash, stateMachine.isGrounded);
    }
    
    protected virtual void HandleJumpLanding(float currentInputMagnitude)
    {
        float jumpTime = GetNormalizedTime(stateMachine.Animator, "Jump");
        if (jumpTime > 0.98f)
        {
            HandleBlendTreeTransition(currentInputMagnitude);

            if (currentInputMagnitude > RunThreshold)
            {
                stateMachine.Animator.CrossFadeInFixedTime(StopRun, CrossFadeDuration);
            }
        }
    }

    public override void Exit()
    {
        stateMachine.InputReader.JumpEvent -= OnJump;
        // stateMachine.InputReader.DashEvent -= OnDash;
        stateMachine.InputReader.DiveEvent -= OnDiveEnter;

        // Camera Out
        stateMachine.mainCamera.Priority = -1;
        UnsubscribeFromInputEvents();
    }
    
    protected virtual void UnsubscribeFromInputEvents()
    {
        stateMachine.InputReader.JumpEvent -= OnJump;
        stateMachine.InputReader.DiveEvent -= OnDiveEnter;
    }
    
    // TODO: Check
    // Not being used right now
    protected virtual void CleanupCamera()
    {
        stateMachine.mainCamera.Priority = -1;
    }
    
    protected virtual void HandleBlendTreeTransition(float inputMagnitude)
    {
        if (inputMagnitude >= IdleThreshold && inputMagnitude < RunThreshold)
        {
            if (lastInputMagnitude < IdleThreshold || lastInputMagnitude >= RunThreshold)
                stateMachine.Animator.CrossFadeInFixedTime(WalkingBlendTreeHash, CrossFadeDuration);
        }
        else
        {
            if (lastInputMagnitude >= IdleThreshold && lastInputMagnitude < RunThreshold)
                stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
        }
    }


    protected bool HasNearbyPaintedEnemy()
    {
        return GameManager.Instance.paintBeacon;
    }
    
    protected virtual void FaceMovementDirection(Vector3 movement, float deltaTime)
    {
        stateMachine.transform.rotation = Quaternion.Lerp(
            stateMachine.transform.rotation,
            Quaternion.LookRotation(movement),
            deltaTime * stateMachine.RotationSpeed);
    }
    
    protected virtual void OnJump()
    {
        if (!CanJump()) return;
        stateMachine.Animator.CrossFadeInFixedTime(AnimJump, CrossFadeDuration);
        Jump();
    }

    protected virtual void OnDiveEnter()
    {
        stateMachine.SwitchState(typeof(PlayerSwimState));
    }

    protected void CameraRecenter()
    {
        CinemachineOrbitalFollow orbitalFollow = stateMachine.mainCamera.gameObject.GetComponent<CinemachineOrbitalFollow>();
        
        float playerYaw = stateMachine.transform.eulerAngles.y;
        orbitalFollow.HorizontalAxis.Value = playerYaw;
        
        orbitalFollow.VerticalAxis.Value = orbitalFollow.VerticalAxis.Center;
        
        orbitalFollow.RadialAxis.Value = orbitalFollow.RadialAxis.Center;
    }
}
