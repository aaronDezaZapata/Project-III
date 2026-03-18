using UnityEngine;

/// <summary>
/// Player Blue State
/// - Basic Movement
/// - Can do Geyser
/// </summary>
public class PlayerBlueState : PlayerWhiteState
{
    // Variables específicas para la habilidad Geyser
    private bool isJumping;
    private float jumpHoldTimer = 0f;
    
    public PlayerBlueState(PlayerStateMachine stateMachine) : base(stateMachine)
    { }

    protected override void SetPlayerState()
    {
        Debug.Log("Entered PlayerBlueState");
        stateMachine.playerState = PlayerStates.BLUE;
    }
    
    protected override void SetMaterialColor()
    {
        //stateMachine.Mat_Player.material.SetColor("_SpecularColor", Color.blue);
        //stateMachine.StartFill(Color.blue);
    }
    
    protected override void InitializeAnimator()
    {
        base.InitializeAnimator();
        jumpHoldTimer = 0f;
    }

    protected override bool CheckColorSpecificActions(float deltaTime)
    {
        UpdateGeyserCooldown(deltaTime);
        
        if (!stateMachine.InputReader.isJumpHeld)
        {
            stateMachine.wasJumpButtonReleased = true;
        }
        
        if (!stateMachine.Controller.isGrounded && stateMachine.InputReader.isJumpHeld)
        {
            if (!stateMachine.isGeyserOnCooldown && stateMachine.wasJumpButtonReleased)
            {
                jumpHoldTimer += deltaTime;

                if (jumpHoldTimer >= stateMachine.GeyserActivationTime && !CanJump() )
                {
                    Debug.Log("Blue: Activando Geyser");
                    stateMachine.SwitchState(typeof(PlayerGeyserState));
                    return true;
                }
            }
        }
        else
        {
            jumpHoldTimer = 0f;
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
        if (!CanJump() || stateMachine.isOnEvent) return;
        isJumping = true;
        stateMachine.Animator.CrossFadeInFixedTime(AnimJump, CrossFadeDuration);
        Jump();
    }
}
