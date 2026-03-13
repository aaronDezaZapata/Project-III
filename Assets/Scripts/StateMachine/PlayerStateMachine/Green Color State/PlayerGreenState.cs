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
        //stateMachine.Mat_Player.material.SetColor("_SpecularColor", Color.green);
        //stateMachine.StartFill(Color.green);
    }
    
    protected override bool CheckColorSpecificActions(float deltaTime)
    {
        if (stateMachine.InputReader.isColorActing && !stateMachine.isOnEvent)
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
    
    // No mods on Tick
    // No mods on Exit 
}
