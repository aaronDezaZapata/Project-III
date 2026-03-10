using UnityEngine;

/// <summary>
/// Player Blue State
/// - Can do heiser movement
/// - Player Basic Movement
/// </summary>
public class PlayerBlueState : PlayerBaseState
{
    private readonly int FreeLookSpeedHash = Animator.StringToHash("SpeedX");
    private readonly int AnimationSpeedHash = Animator.StringToHash("AimSpeedX");
    private readonly int VerticalSpeedHash = Animator.StringToHash("SpeedY");
    private readonly int GroundedHash = Animator.StringToHash("IsGrounded");
    
    private readonly int FreeLookBlendTreeHash = Animator.StringToHash("FreeLookBlendTree");
    private readonly int WalkingBlendTreeHash = Animator.StringToHash("WalkingBlendTree");
    
    private readonly int StopRun = Animator.StringToHash("StopRun");

    private readonly int AnimJump = Animator.StringToHash("Impulse");
    
    private const float AnimatorDampTime = 0.1f;
    private const float CrossFadeDuration = 0.1f;

    private const float RunThreshold = 0.7f;
    private const float IdleThreshold = 0.05f;
    
    private float lastSpeed;
    private float lastInputMagnitude;
    
    // Heiser action variable
    private bool isJumping;
    private float jumpHoldTimer = 0f;
    
    public PlayerBlueState(PlayerStateMachine stateMachine) : base(stateMachine)
    { }

    public override void Enter()
    {
        Debug.Log("Entering PlayerBlueState");
        stateMachine.mainCamera.Priority = 10;
        
        stateMachine.playerState = PlayerStates.BLUE;
        
        stateMachine.Animator.SetFloat(FreeLookSpeedHash, 0);
        stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
        
        jumpHoldTimer = 0f;
        
        stateMachine.InputReader.JumpEvent += OnJump;
        stateMachine.InputReader.DiveEvent += OnDiveEnter;
        
        stateMachine.Animator.SetFloat(FreeLookSpeedHash, 0);
        stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
        lastSpeed = 0f;
        lastInputMagnitude = 0f;
    }

    public override void Tick(float deltaTime)
    {
        stateMachine.CheckGrounded();
        if (!stateMachine.Controller.isGrounded && stateMachine.InputReader.isJumpHeld)
        {
            jumpHoldTimer += deltaTime;
            
            if (jumpHoldTimer >= stateMachine.HeiserActivationTime)
            {
                stateMachine.SwitchState(typeof(PlayerHeiserState));
                return;
            }
        }
        else
        {
            jumpHoldTimer = 0f;
        }

        Vector3 movement = stateMachine.CalculateMovement();
        float currentInputMagnitude = movement.magnitude;
        
        stateMachine.Animator.SetFloat(FreeLookSpeedHash, currentInputMagnitude, AnimatorDampTime, deltaTime);
        stateMachine.Animator.SetFloat(AnimationSpeedHash, movement.x, AnimatorDampTime, deltaTime);
        stateMachine.Animator.SetFloat(VerticalSpeedHash, stateMachine.Controller.velocity.y, AnimatorDampTime, deltaTime);
        stateMachine.Animator.SetBool(GroundedHash, stateMachine.isGrounded);
        
        HandleBlendTreeTransition(currentInputMagnitude);
        if (currentInputMagnitude > RunThreshold)
        {
            FaceMovementDirection(movement, deltaTime);
        }

        float jumpTime = GetNormalizedTime(stateMachine.Animator, "Jump");
        if(jumpTime > 0.98f)
        {
            HandleBlendTreeTransition(currentInputMagnitude);
            
            if (currentInputMagnitude > RunThreshold)
            {
                stateMachine.Animator.CrossFadeInFixedTime(StopRun, CrossFadeDuration);
            }
            
            // stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
        }

        // stateMachine.Animator.SetFloat(FreeLookSpeedHash, movement.magnitude, AnimatorDampTime, deltaTime);
        
        /*if (!Equals(movement, Vector3.zero))
        {
            FaceMovementDirection(movement, deltaTime);
        }*/
        
        Move(movement * stateMachine.FreeLookMovementSpeed, deltaTime);
        
        lastSpeed = currentInputMagnitude;
        lastInputMagnitude = currentInputMagnitude;
    }

    public override void Exit()
    {
        Debug.Log("Exiting PlayerBlueState");
        
        stateMachine.InputReader.JumpEvent -= OnJump;
        stateMachine.InputReader.DiveEvent -= OnDiveEnter;
    }
    
    private void FaceMovementDirection(Vector3 movement, float deltaTime)
    {
        stateMachine.transform.rotation = Quaternion.Lerp(
            stateMachine.transform.rotation,
            Quaternion.LookRotation(movement),
            deltaTime * stateMachine.RotationSpeed);
    }
    
    private void OnJump()
    {
        if (!CanJump()) return;
        isJumping = true;
        stateMachine.Animator.CrossFadeInFixedTime(AnimJump, CrossFadeDuration);
        Jump();
    }
    
    private void OnDiveEnter()
    {
        stateMachine.SwitchState(typeof(PlayerSwimState));
    }
    
    private void HandleBlendTreeTransition(float inputMagnitude)
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
}
