using FMOD.Studio;
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
    /// Animation Hashes ///
    // Movement
    protected readonly int SpeedX = Animator.StringToHash("SpeedX");
    protected readonly int AimSpeedX = Animator.StringToHash("AimSpeed");
    protected readonly int SpeedY = Animator.StringToHash("SpeedY");
    protected readonly int IsGrounded = Animator.StringToHash("IsGrounded");
    protected readonly int IsFalling = Animator.StringToHash("IsFalling");
    
    protected readonly int AnimJump = Animator.StringToHash("JumpTriggered");

    protected const float RunThreshold = 0.7f;
    protected const float IdleThreshold = 0.05f;
    
    // Movement Tracking
    protected float currentSpeed;
    protected float smoothSpeed;
    
    // State tracking
    protected float lastSpeed = 0f;
    protected float lastInputMagnitude = 0f;

    //Audio 
    private bool audioWasGrounded;
    private bool fallAudioPlayed;
    private float lastVerticalVelocity;


    public PlayerWhiteState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }


    public override void Enter()
    {
        SetPlayerState();
        SetMaterialColor();
        SubscribeToInputEvents();

        stateMachine.CheckGrounded();

        Vector3 movement = stateMachine.CalculateMovement();
        UpdateAnimatorParameters(movement, movement.magnitude, Time.deltaTime);

        InitializeAnimator();

        audioWasGrounded = stateMachine.isGrounded;
        fallAudioPlayed = false;
        lastVerticalVelocity = stateMachine.Controller.velocity.y;

    }

    // Default player state
    // Overridden in other states
    protected virtual void SetPlayerState()
    {
    }
    
    // Initial material color config
    protected virtual void SetMaterialColor()
    {
    }
    
    // Input events to subscribe
    protected virtual void SubscribeToInputEvents()
    {
        stateMachine.InputReader.JumpEvent += OnJump;
        stateMachine.InputReader.DiveEvent += OnDiveEnter;
        stateMachine.InputReader.SwitchColorEvent += stateMachine.RotateColors;
        InputHandler.InteractionEvent += stateMachine.HandlePuddleInteraction;
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
        float currentSpeed = stateMachine.Animator.GetFloat(SpeedX);
        
        if (stateMachine.isGrounded)
        {
            stateMachine.Animator.SetBool(IsGrounded, true);
        }
        
        lastInputMagnitude = currentSpeed;
        lastSpeed = currentSpeed;
    }

    public override void Tick(float deltaTime)
    {
        if (stateMachine.isOnEvent && stateMachine.isRestrictedToForwardBackward)
        {
            HandleEventMovement(deltaTime);
            return;
        }

        if (stateMachine.isOnEvent) return;
        
        stateMachine.CheckGrounded();
        stateMachine.ApplySlopeSlide();
        
        // Check for color-specific actions
        if (CheckColorSpecificActions(deltaTime)) return; 
        

        // Calculate movement
        Vector3 movement = stateMachine.CalculateMovement();
        float currentInputMagnitude = movement.magnitude;

        // Update animator parameters
        UpdateAnimatorParameters(movement, currentInputMagnitude, deltaTime);

        // Face movement direction if running
        if (currentInputMagnitude > RunThreshold)
        {
            FaceMovementDirection(movement, deltaTime);
        }

        // Apply movement
        Move(movement * stateMachine.FreeLookMovementSpeed, deltaTime);

        if(stateMachine.ShadowDrop != null && !stateMachine.isGrounded)
        {
            if (!stateMachine.ShadowDrop.gameObject.activeSelf) { stateMachine.ShadowDrop.gameObject.SetActive(true); }

            stateMachine.AddShadowDrop();
        }
        else
        {
            stateMachine.ShadowDrop.gameObject.SetActive(false);
        }

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
        float targetSpeed = currentInputMagnitude;
        
        currentSpeed = Mathf.Lerp(currentSpeed, targetSpeed, Time.deltaTime * 8f);
        
        stateMachine.Animator.SetFloat(SpeedX, Mathf.Abs(currentSpeed));
        
        stateMachine.Animator.SetFloat(AimSpeedX, movement.x);
        stateMachine.Animator.SetFloat(SpeedY, stateMachine.Controller.velocity.y);
        stateMachine.Animator.SetBool(IsGrounded, stateMachine.isGrounded);
        
        bool isFalling = !stateMachine.isGrounded && stateMachine.Controller.velocity.y < -0.5f;
        stateMachine.Animator.SetBool(IsFalling, isFalling);
    }
    
    public override void Exit()
    {
        stateMachine.InputReader.JumpEvent -= OnJump;
        stateMachine.InputReader.DiveEvent -= OnDiveEnter;

        UnsubscribeFromInputEvents();
    }
    
    protected virtual void UnsubscribeFromInputEvents()
    {
        stateMachine.InputReader.JumpEvent -= OnJump;
        stateMachine.InputReader.DiveEvent -= OnDiveEnter;
        stateMachine.InputReader.SwitchColorEvent -= stateMachine.RotateColors;
        InputHandler.InteractionEvent -= stateMachine.HandlePuddleInteraction;
    }
    
    // TODO: Check
    // Not being used right now
    protected virtual void CleanupCamera()
    {
        stateMachine.mainCamera.Priority = -1;
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
        if (!CanJump() || stateMachine.isOnEvent || stateMachine.isOnSteepSlope) return;
        stateMachine.Animator.SetTrigger(AnimJump);
        Jump();
    }

    protected virtual void OnDiveEnter()
    {        
        stateMachine.CheckForInk();
        if (stateMachine.IsOnInk)
        if (stateMachine.IsOnInk || stateMachine.isOnEvent)
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

    protected void HandleEventMovement(float deltaTime)
    {
        Vector3 movement = stateMachine.CalculateMovement();
        
        Vector3 forward = stateMachine.eventForwardDirection;
        Vector3 right = Vector3.Cross(forward, Vector3.up);
        
        float forwardInput = stateMachine.InputReader.MoveVector.y;
        float rightInput = stateMachine.InputReader.MoveVector.x;
        
        Vector3 restrictedMovement = (forward * forwardInput) * stateMachine.FreeLookMovementSpeed;
        
        float currentInputMagnitude = Mathf.Abs(forwardInput);
        UpdateAnimatorParameters(restrictedMovement, currentInputMagnitude, deltaTime);
        
        if (currentInputMagnitude > IdleThreshold)
        {
            FaceMovementDirection(restrictedMovement, deltaTime);
        }
        
        Move(restrictedMovement, deltaTime);
    }
}
