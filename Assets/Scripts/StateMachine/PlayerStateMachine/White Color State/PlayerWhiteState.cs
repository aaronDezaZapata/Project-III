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
    // Animation Hashes
    protected readonly int FreeLookSpeedHash = Animator.StringToHash("SpeedX");
    protected readonly int AnimationSpeedHash = Animator.StringToHash("AimSpeedX");
    protected readonly int VerticalSpeedHash = Animator.StringToHash("SpeedY");
    protected readonly int GroundedHash = Animator.StringToHash("IsGrounded");
    protected readonly int IsFallingHash = Animator.StringToHash("IsFalling");
    
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

    //Audio 
    private bool audioWasGrounded;
    private bool fallAudioPlayed;
    private float lastVerticalVelocity;

    private int inkLayer;
    private int leavesLayer;
    private int rockLayer;
    private int sandLayer;
    private int woodLayer;

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

        inkLayer = LayerMask.NameToLayer("Ink");
        leavesLayer = LayerMask.NameToLayer("Leaves");
        rockLayer = LayerMask.NameToLayer("Rock");
        sandLayer = LayerMask.NameToLayer("Sand");
        woodLayer = LayerMask.NameToLayer("Wood");
    }

    // Default player state
    // Overridden in other states
    protected virtual void SetPlayerState()
    {
        //stateMachine.playerState = PlayerStates.WHITE;
    }
    
    // Initial material color config
    protected virtual void SetMaterialColor()
    {
        //stateMachine.Mat_Player.material.SetColor("_SpecularColor", Color.white);
        //stateMachine.StartFill(Color.white);
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
        float currentSpeed = stateMachine.Animator.GetFloat(FreeLookSpeedHash);
        
        // No forzar transición a locomoción si el jugador está en el aire
        // Dejar que las transiciones del Animator manejen el estado según IsGrounded y IsFalling
        if (stateMachine.isGrounded)
        {
            stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
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

        float moveSpeed = currentInputMagnitude * stateMachine.FreeLookMovementSpeed;
        bool isMoving = currentInputMagnitude > IdleThreshold;
        FootstepSurfaceType surfaceType = GetCurrentFootstepSurface();

        stateMachine.PlayerAudio?.UpdateFootsteps(moveSpeed, surfaceType, stateMachine.isGrounded, isMoving);

        // Fall audio
        if (!stateMachine.isGrounded && stateMachine.Controller.velocity.y < -0.5f && !fallAudioPlayed)
        {
            stateMachine.PlayerAudio?.PlayFall();
            fallAudioPlayed = true;
        }

        // Landing audio
        if (!audioWasGrounded && stateMachine.isGrounded)
        {
            if (lastVerticalVelocity < -8f)
                stateMachine.PlayerAudio?.PlayHeavyImpact();
            else
                stateMachine.PlayerAudio?.PlayLanding();

            fallAudioPlayed = false;
        }

        if (stateMachine.isGrounded)
            fallAudioPlayed = false;

        audioWasGrounded = stateMachine.isGrounded;
        lastVerticalVelocity = stateMachine.Controller.velocity.y;

        // Handle blend tree transitions
        if (stateMachine.isGrounded)
        {
            HandleBlendTreeTransition(currentInputMagnitude);
        }

        // Face movement direction if running
        if (currentInputMagnitude > RunThreshold)
        {
            FaceMovementDirection(movement, deltaTime);
        }

        // Handle jump landing
        HandleJumpLanding(currentInputMagnitude);

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
        stateMachine.Animator.SetFloat(FreeLookSpeedHash, currentInputMagnitude, AnimatorDampTime, deltaTime);
        stateMachine.Animator.SetFloat(AnimationSpeedHash, movement.x, AnimatorDampTime, deltaTime);
        stateMachine.Animator.SetFloat(VerticalSpeedHash, stateMachine.Controller.velocity.y, AnimatorDampTime, deltaTime);
        stateMachine.Animator.SetBool(GroundedHash, stateMachine.isGrounded);
        
        bool isFalling = !stateMachine.isGrounded && stateMachine.Controller.velocity.y < -0.5f;
        stateMachine.Animator.SetBool(IsFallingHash, isFalling);
    }
    
    protected virtual void HandleJumpLanding(float currentInputMagnitude)
    {
        float jumpTime = GetNormalizedTime(stateMachine.Animator, "Jump");
        if (jumpTime > 0.98f)
        {
            HandleBlendTreeTransition(currentInputMagnitude);
        }
    }

    private FootstepSurfaceType GetCurrentFootstepSurface()
    {
        Vector3 origin = stateMachine.transform.position + Vector3.up * 0.2f;

        if (Physics.Raycast(origin, Vector3.down, out RaycastHit hit, 2f))
        {
            int layer = hit.collider.gameObject.layer;

            if (layer == inkLayer)
                return FootstepSurfaceType.Ink;

            if (layer == leavesLayer)
                return FootstepSurfaceType.Leaves;

            if (layer == sandLayer)
                return FootstepSurfaceType.Sand;

            if (layer == woodLayer)
                return FootstepSurfaceType.Wood;

            if (layer == rockLayer)
                return FootstepSurfaceType.Rock;
        }

        return FootstepSurfaceType.Rock;
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
    
    protected virtual void HandleBlendTreeTransition(float inputMagnitude)
    {
        // PlayerWhiteState solo usa FreeLookBlendTree
        // No hace transiciones entre diferentes blend trees, el FreeLookBlendTree maneja idle/walk/run
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
        stateMachine.Animator.CrossFadeInFixedTime(AnimJump, CrossFadeDuration);
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
