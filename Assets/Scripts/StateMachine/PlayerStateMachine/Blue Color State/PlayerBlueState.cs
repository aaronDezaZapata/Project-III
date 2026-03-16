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
    }

    protected override bool CheckColorSpecificActions(float deltaTime)
    {
        UpdateHeiserCooldown(deltaTime);
        
        if (!stateMachine.InputReader.isJumpHeld)
        {
            stateMachine.wasJumpButtonReleased = true;
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
        if (stateMachine.isOnEvent) return;

        if (!CanJump())
        {
            // Activate Heiser on 3rd jump (when standard jumps are exhausted)
            if (!stateMachine.Controller.isGrounded && !stateMachine.isHeiserOnCooldown)
            {
                Debug.Log("Blue: Activando Heiser (Triple Jump)");
                stateMachine.SwitchState(typeof(PlayerHeiserState));
            }
            return;
        }

        isJumping = true;
        stateMachine.Animator.CrossFadeInFixedTime(AnimJump, CrossFadeDuration);
        Jump();
    }
}
