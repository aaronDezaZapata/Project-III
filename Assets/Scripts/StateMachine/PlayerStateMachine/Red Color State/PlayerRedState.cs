using UnityEngine;

/// <summary>
/// Player Red State
/// - Basic Movement
/// - Can Shoot ink
/// </summary>
public class PlayerRedState : PlayerWhiteState
{
    public PlayerRedState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    protected override void SetPlayerState()
    {
        stateMachine.playerState = PlayerStates.RED;

    }
    
    protected override bool CheckColorSpecificActions(float deltaTime)
    {
        if (stateMachine.InputReader.isAiming && !stateMachine.isOnEvent)
        {
            stateMachine.SwitchState(typeof(PlayerShootingState));
            return true;
        }
        return false;
    }

}
