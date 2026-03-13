using UnityEngine;

/// <summary>
/// Player Green State
/// - Basic Movement
/// - Can do Whip
/// </summary>
public class PlayerGreenState : PlayerWhiteState
{
    public PlayerGreenState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    
    protected override void SetPlayerState()
    {
        Debug.Log("Entered PlayerGreenState");
        stateMachine.playerState = PlayerStates.GREEN;
    }
    
    protected override void SetMaterialColor()
    {
        stateMachine.Mat_Player.material.SetColor("_SpecularColor", Color.green);
    }
    
    protected override bool CheckColorSpecificActions(float deltaTime)
    {
        if (stateMachine.InputReader.isColorActing)
        {
            if (!stateMachine.WhipFailedLastAttempt)
            {
                stateMachine.SwitchState(typeof(PlayerWhipState));
                return true;
            }
        }
        else
        {
            stateMachine.WhipFailedLastAttempt = false;
        }
        
        return false;
    }
    
    // Tick se hereda de PlayerWhiteState con CheckColorSpecificActions sobrescrito
    // No mods on Tick right now

    // Exit se hereda de PlayerWhiteState - no necesita sobrescritura
    // No mods on Exit right now
}
