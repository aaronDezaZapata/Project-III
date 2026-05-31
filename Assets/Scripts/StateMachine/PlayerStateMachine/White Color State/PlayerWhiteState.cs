using FMOD.Studio;
using Unity.Cinemachine;
using UnityEngine;

public class PlayerWhiteState : PlayerBaseState
{
    protected readonly int SpeedX = Animator.StringToHash("SpeedX");
    protected readonly int AimSpeedX = Animator.StringToHash("AimSpeed");
    protected readonly int SpeedY = Animator.StringToHash("SpeedY");
    protected readonly int IsGrounded = Animator.StringToHash("IsGrounded");
    protected readonly int IsFalling = Animator.StringToHash("IsFalling");

    protected const float RunThreshold = 0.7f;
    protected const float IdleThreshold = 0.05f;
    
    protected float currentSpeed;
    


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
        
    }

    protected virtual void SetPlayerState()
    {
    }
    
    protected virtual void SetMaterialColor()
    {
    }
    
    protected virtual void SubscribeToInputEvents()
    {
        stateMachine.InputReader.JumpEvent += OnJump;
        stateMachine.InputReader.DiveEvent += OnDiveEnter;
        stateMachine.InputReader.SwitchColorEvent += stateMachine.RotateColors;
        InputHandler.InteractionEvent += stateMachine.HandlePuddleInteraction;
    }
    
    protected virtual void InitializeAnimator()
    {
        if (stateMachine.isGrounded)
        {
            stateMachine.Animator.SetBool(IsGrounded, true);
        }
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
        
        if (CheckColorSpecificActions(deltaTime)) return; 
        
        
        Vector3 movement = stateMachine.CalculateMovement();
        float currentInputMagnitude = movement.magnitude;
        
        UpdateAnimatorParameters(movement, currentInputMagnitude, deltaTime);
        
        if (currentInputMagnitude > RunThreshold)
        {
            FaceMovementDirection(movement, deltaTime);
        }
        
        Move(movement * stateMachine.FreeLookMovementSpeed, deltaTime);
    }

    protected virtual bool CheckColorSpecificActions(float deltaTime) { return false; }
    
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
        UnsubscribeFromInputEvents();
    }
    
    protected virtual void UnsubscribeFromInputEvents()
    {
        stateMachine.InputReader.JumpEvent -= OnJump;
        stateMachine.InputReader.DiveEvent -= OnDiveEnter;
        stateMachine.InputReader.SwitchColorEvent -= stateMachine.RotateColors;
        InputHandler.InteractionEvent -= stateMachine.HandlePuddleInteraction;
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
        Jump();
    }

    protected virtual void OnDiveEnter()
    {        
        stateMachine.CheckForInk();
        if (stateMachine._isOnInk)
        if (stateMachine._isOnInk || stateMachine.isOnEvent)
            stateMachine.SwitchState(typeof(PlayerSwimState));
    }

    protected void HandleEventMovement(float deltaTime)
    {
        Vector3 forward = stateMachine.eventForwardDirection;
        
        float forwardInput = stateMachine.InputReader.MoveVector.y;
        
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
