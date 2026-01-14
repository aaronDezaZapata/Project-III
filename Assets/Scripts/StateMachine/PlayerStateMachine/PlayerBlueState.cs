using UnityEngine;

/// <summary>
/// Player Blue State
/// - Player Shoot increases enemy size a little bit until he explodes.
/// - Can do heiser movement
/// </summary>
public class PlayerBlueState : PlayerBaseState
{
    private readonly int FreeLookSpeedHash = Animator.StringToHash("Speed");

    private readonly int FreeLookBlendTreeHash = Animator.StringToHash("FreeLookBlendTree");

    private const float CrossFadeDuration = 0.1f;

    private const float AnimatorDampTime = 0.1f;

    public PlayerBlueState(PlayerStateMachine stateMachine) : base(stateMachine)
    { }

    public override void Enter()
    {
        stateMachine.playerState = PlayerStates.BLUE;

        stateMachine.Animator.SetFloat(FreeLookSpeedHash, 0);

        stateMachine.Animator.CrossFadeInFixedTime(FreeLookBlendTreeHash, CrossFadeDuration);
    }

    public override void Tick(float deltaTime)
    {
        // Heiser
        
        if (stateMachine.InputReader.isColorActing)
        {
            stateMachine.SwitchState(typeof(PlayerHeiserState));
        }

        Vector3 movement = stateMachine.CalculateMovement();
        if (!Equals(movement, Vector3.zero))
        {
            FaceMovementDirection(movement, deltaTime);
            stateMachine.Animator.SetFloat(FreeLookSpeedHash, movement.normalized.magnitude, AnimatorDampTime, deltaTime);
        }

        Move(movement * stateMachine.FreeLookMovementSpeed, deltaTime);
    }

    public override void Exit()
    {
        
    }

    private void FaceMovementDirection(Vector3 movement, float deltaTime)
    {
        stateMachine.transform.rotation = Quaternion.Lerp(
            stateMachine.transform.rotation,
            Quaternion.LookRotation(movement),
            deltaTime * stateMachine.RotationSpeed);

    }
}
