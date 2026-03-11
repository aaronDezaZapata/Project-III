using UnityEngine;

/// <summary>
/// Player Blue State
/// - Basic Movement
/// - Can do Heiser Hability
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
        if (!stateMachine.Controller.isGrounded && stateMachine.InputReader.isJumpHeld)
        {
            jumpHoldTimer += deltaTime;
            
            if (jumpHoldTimer >= stateMachine.HeiserActivationTime)
            {
                stateMachine.SwitchState(typeof(PlayerHeiserState));
                return true;
            }
        }
        else
        {
            jumpHoldTimer = 0f;
        }
        
        return false; // No dash attack para Blue
    }
    
    protected override void OnJump()
    {
        if (!CanJump()) return;
        isJumping = true;
        stateMachine.Animator.CrossFadeInFixedTime(AnimJump, CrossFadeDuration);
        Jump();
    }
    
    // No mods on Tick right now
    
    // No mods on Exit right now
}
