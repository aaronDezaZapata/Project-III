using UnityEngine;

/// <summary>
/// Player Heiser State (Blue Ability)
/// - Vertical Movement
/// - Deactivates at grounded or when jump button is released
/// - Cooldown before reusing the ability
/// </summary>
public class PlayerHeiserState : PlayerBaseState
{
    private readonly int Heiser = Animator.StringToHash("GeiserCycle");
    private const float CrossFadeDuration = 0.1f;
    
    public PlayerHeiserState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        Debug.Log("Entered PlayerHeiserState");
        
        stateMachine.UseColor(0.5f);
        stateMachine.Animator.CrossFadeInFixedTime(Heiser, CrossFadeDuration);
        stateMachine.WaterHeiserParticle.gameObject.SetActive(true);
        stateMachine.WaterHeiserParticleSecond.gameObject.SetActive(true);
        stateMachine.mainCamera.Priority = 10;
        
        stateMachine.ForceReceiver.Jump(stateMachine.HeiserInitialBoostForce);
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
        
        stateMachine.ForceReceiver.AddForce(Vector3.up * stateMachine.HoverForce * deltaTime);
        MoveHoverDirect(deltaTime);
    }

    public override void Exit()
    {
        stateMachine.isHeiserOnCooldown = true;
        stateMachine.heiserCooldownTimer = stateMachine.HeiserCooldownTime;
        stateMachine.wasJumpButtonReleased = false;
        
        stateMachine.WaterHeiserParticle.gameObject.SetActive(false);
        stateMachine.WaterHeiserParticleSecond.gameObject.SetActive(false);
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
