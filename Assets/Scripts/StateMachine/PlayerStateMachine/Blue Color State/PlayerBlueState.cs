using UnityEngine;

/// <summary>
/// Player Blue State
/// - Basic Movement
/// - Geyser se activa en el 3er salto
///   manteniendo el botón de salto
/// - Una vez salido del Geyser en el aire, no se puede re-entrar hasta tocar suelo
/// </summary>
public class PlayerBlueState : PlayerWhiteState
{
    private bool geyserReady;
    private bool geyserUsedThisAirTime;
    
    public PlayerBlueState(PlayerStateMachine stateMachine) : base(stateMachine)
    { }

    protected override void SetPlayerState()
    {
        stateMachine.playerState = PlayerStates.BLUE;
    }
    
    protected override bool CheckColorSpecificActions(float deltaTime)
    {
        UpdateGeyserCooldown(deltaTime);
        
       
        if (stateMachine.isGrounded)
        {
            geyserReady = false;
            geyserUsedThisAirTime = false;
        }
        
        
        if (!stateMachine.InputReader.isJumpHeld)
        {
            geyserReady = false;
        }
        
        
        if (geyserReady && !geyserUsedThisAirTime && stateMachine.InputReader.isJumpHeld)
        {
            geyserUsedThisAirTime = true;
            geyserReady = false;
            
            stateMachine.SwitchState(typeof(PlayerGeyserState));
            return true;
        }
        
        return false;
    }
    
    private void UpdateGeyserCooldown(float deltaTime)
    {
        if (stateMachine.isGeyserOnCooldown)
        {
            stateMachine.geyserCooldownTimer -= deltaTime;
            
            if (stateMachine.geyserCooldownTimer <= 0f)
            {
                stateMachine.isGeyserOnCooldown = false;
                stateMachine.geyserCooldownTimer = 0f;
            }
        }
    }
    
    protected override void OnJump()
    {
        if (stateMachine.isOnEvent) return;
        
        if (CanJump())
        {
            stateMachine.Animator.SetTrigger(AnimJump);
            Jump();
        }
        else if (!stateMachine.isGrounded && !geyserUsedThisAirTime)
        {
            geyserReady = true;
        }
    }
}
