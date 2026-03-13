using UnityEngine;

/// <summary>
/// Player Blue State
/// - Basic Movement
/// - Can do Heiser
/// </summary>
public class PlayerBlueState : PlayerWhiteState
{
    // Variables específicas para la habilidad Heiser
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
        stateMachine.Mat_Player.material.SetColor("_SpecularColor", Color.blue);
    }
    
    protected override void InitializeAnimator()
    {
        base.InitializeAnimator();
        jumpHoldTimer = 0f;
    }

    protected override bool CheckColorSpecificActions(float deltaTime)
    {
        UpdateHeiserCooldown(deltaTime);
        
        if (!stateMachine.InputReader.isJumpHeld)
        {
            stateMachine.wasJumpButtonReleased = true;
        }
        
        if (!stateMachine.Controller.isGrounded && stateMachine.InputReader.isJumpHeld)
        {
            if (!stateMachine.isHeiserOnCooldown && stateMachine.wasJumpButtonReleased)
            {
                jumpHoldTimer += deltaTime;
                
                if (jumpHoldTimer >= stateMachine.HeiserActivationTime)
                {
                    Debug.Log("Blue: Activando Heiser");
                    stateMachine.SwitchState(typeof(PlayerHeiserState));
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
    
    private void UpdateHeiserCooldown(float deltaTime)
    {
        if (stateMachine.isHeiserOnCooldown)
        {
            stateMachine.heiserCooldownTimer -= deltaTime;
            
            if (stateMachine.heiserCooldownTimer <= 0f)
            {
                stateMachine.isHeiserOnCooldown = false;
                stateMachine.heiserCooldownTimer = 0f;
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
