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
        Debug.Log("Entered PlayerRedState");
        stateMachine.playerState = PlayerStates.RED;
    }
    
    protected override void SetMaterialColor()
    {
        stateMachine.Mat_Player.material.SetColor("_SpecularColor", Color.red);
    }

    protected override bool CheckColorSpecificActions(float deltaTime)
    {
        // Red puede apuntar y disparar
        if (stateMachine.InputReader.isAiming && !stateMachine.isOnEvent)
        {
            stateMachine.SwitchState(typeof(PlayerShootingState));
            return true;
        }

        if (stateMachine.InputReader.isColorActing && !stateMachine.isOnEvent)
        {
            if (GameManager.Instance.paintBeacon == null) return false;
            stateMachine.SwitchState(typeof(PlayerDashAttackState));
            return true;
        }
        
        return false;
    }

    // No mods on Tick right now
    
    // No mods on Exit right now
}
