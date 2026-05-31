using UnityEngine;

public class PlayerGeyserState : PlayerBaseState
{
    private readonly int _isOnGeyser = Animator.StringToHash("IsOnGeyser");

    public PlayerGeyserState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        Jump();
        
        if (stateMachine.ForceReceiver.VerticalVelocity < 0f)
        {
            stateMachine.ForceReceiver.Jump(0f);
        }
        
        stateMachine.UseColor(0.5f);
        stateMachine.WaterGeyserParticle.gameObject.SetActive(true);
        stateMachine.WaterGeyserParticleSecond.gameObject.SetActive(true);
        stateMachine.MainCamera.Priority = 10;

        stateMachine.PlayerAudio?.PlayBlueActivate();
        stateMachine.PlayerAudio?.PlayBlueBoost();
        stateMachine.PlayerAudio?.StartBlueGeyserLoop();

        stateMachine.Animator.SetBool(_isOnGeyser, true);
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
        stateMachine.isGeyserOnCooldown = true;
        stateMachine.geyserCooldownTimer = stateMachine.GeyserCooldownTime;
        
        stateMachine.WaterGeyserParticle.gameObject.SetActive(false);
        stateMachine.WaterGeyserParticleSecond.gameObject.SetActive(false);

        stateMachine.PlayerAudio?.StopBlueGeyserLoop();

        stateMachine.Animator.SetBool(_isOnGeyser, false);
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
        
        Vector3 velocity = moveDir * stateMachine.AerialMoveSpeed;
        
        Vector3 finalMovement = velocity + stateMachine.ForceReceiver.Movement;
        
        stateMachine.Controller.Move(finalMovement * deltaTime);
    }
}
