using UnityEngine;

/// <summary>
/// Player Geyser State (Blue Ability)
/// - Vertical Movement
/// - Deactivates at grounded or when jump button is released
/// - Cooldown before reusing the ability
/// </summary>
public class PlayerGeyserState : PlayerBaseState
{
    private readonly int GeyserAnim = Animator.StringToHash("GeyserCycle");
    private const float CrossFadeDuration = 0.1f;
    private const float AirControlSfxInterval = 0.20f;

    private float airControlSfxTimer;

    public PlayerGeyserState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        Jump();
        
        // Reset down velocity 
        if (stateMachine.ForceReceiver.VerticalVelocity < 0f)
        {
            stateMachine.ForceReceiver.Jump(0f);
        }
        
        stateMachine.UseColor(0.5f);
        stateMachine.WaterGeyserParticle.gameObject.SetActive(true);
        stateMachine.WaterGeyserParticleSecond.gameObject.SetActive(true);
        stateMachine.mainCamera.Priority = 10;

        stateMachine.PlayerAudio?.PlayBlueActivate();
        stateMachine.PlayerAudio?.PlayBlueBoost();

        airControlSfxTimer = 0f;
        
        stateMachine.Animator.SetBool(GeyserAnim, true);
    }

    public override void Tick(float deltaTime)
    {
        stateMachine.CheckGrounded();
        if (stateMachine.Controller.isGrounded)
        {
            stateMachine.SwitchState(typeof(PlayerBlueState));
            return;
        }
        
        if (!stateMachine.InputReader.isJumpHeld)
        {
            stateMachine.SwitchState(typeof(PlayerBlueState));
            return;
        }

        if (stateMachine.InputReader.MoveVector.sqrMagnitude > 0.01f)
        {
            airControlSfxTimer -= deltaTime;
            if (airControlSfxTimer <= 0f)
            {
                stateMachine.PlayerAudio?.PlayBlueAirControl();
                airControlSfxTimer = AirControlSfxInterval;
            }
        }
        else
        {
            airControlSfxTimer = 0f;
        }

        stateMachine.ForceReceiver.AddForce(Vector3.up * stateMachine.HoverForce * deltaTime);
        MoveHoverDirect(deltaTime);
    }

    public override void Exit()
    {
        stateMachine.Animator.SetBool(GeyserAnim, false);
        
        stateMachine.isGeyserOnCooldown = true;
        stateMachine.geyserCooldownTimer = stateMachine.GeyserCooldownTime;
        stateMachine.wasJumpButtonReleased = false;
        
        stateMachine.WaterGeyserParticle.gameObject.SetActive(false);
        stateMachine.WaterGeyserParticleSecond.gameObject.SetActive(false);
    }
    
    private void MoveHoverDirect(float deltaTime)
    {
        Vector3 input = stateMachine.InputReader.MoveVector;
        
        Vector3 forward = Camera.main.transform.forward;
        Vector3 right = Camera.main.transform.right;
        forward.y = 0;
        right.y = 0;
        forward.Normalize();
        right.Normalize();

        Vector3 moveDir = forward * input.y + right * input.x;
        
        if (moveDir != Vector3.zero)
        {
            stateMachine.transform.rotation = Quaternion.Slerp(
                stateMachine.transform.rotation,
                Quaternion.LookRotation(moveDir),
                stateMachine.RotationSpeed * deltaTime
            );
        }
        
        Vector3 velocity = moveDir * stateMachine.aerialMoveSpeed;
        
        Vector3 finalMovement = velocity + stateMachine.ForceReceiver.Movement;
        
        stateMachine.Controller.Move(finalMovement * deltaTime);
    }
}
