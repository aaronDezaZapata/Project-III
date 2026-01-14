using UnityEngine;

/// <summary>
/// Player Blue State
/// - Player Shoot increases enemy size a little bit until he explodes.
/// - Can do heiser movement
/// </summary>
public class PlayerBlueState : PlayerBaseState
{
    public PlayerBlueState(PlayerStateMachine stateMachine) : base(stateMachine)
    { }

    public override void Enter()
    {
        stateMachine.playerState = PlayerStates.BLUE;
    }

    public override void Tick(float deltaTime)
    {
        // Heiser
        
        if (stateMachine.InputReader.isColorActing)
        {
            stateMachine.SwitchState(typeof(PlayerHeiserState));
        }
    }

    public override void Exit()
    {
        
    }
}
