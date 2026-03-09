using UnityEngine;

/// <summary>
/// Player Blue State
/// - Can do heiser movement
/// </summary>
public class PlayerBlueState : PlayerBaseState
{
    private readonly int FreeLookSpeedHash = Animator.StringToHash("Speed");
    private readonly int FreeLookBlendTreeHash = Animator.StringToHash("FreeLookBlendTree");
    private readonly int AnimJump = Animator.StringToHash("Jump");
    
    private const float AnimatorDampTime = 0.1f;
    private const float CrossFadeDuration = 0.1f;

    bool isJumping;
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

        float jumpTime = GetNormalizedTime(stateMachine.Animator, "Jump");

        if(jumpTime > 0.98f)
        {
            stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
        }

        stateMachine.Animator.SetFloat(FreeLookSpeedHash, movement.magnitude, AnimatorDampTime, deltaTime);
        
        if (!Equals(movement, Vector3.zero))
        {
            FaceMovementDirection(movement, deltaTime);
        }
        
        Move(movement * stateMachine.FreeLookMovementSpeed, deltaTime);
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
}
