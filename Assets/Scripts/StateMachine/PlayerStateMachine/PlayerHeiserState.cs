using UnityEngine;

/// <summary>
/// Heiser Movement
/// - Just a plain vertical movement
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
        stateMachine.CanHeiser = true;
        stateMachine.CanHeiser = false;
        stateMachine.Animator.CrossFadeInFixedTime(Heiser, CrossFadeDuration);
        stateMachine.mainCamera.Priority = 10;
    }

    public override void Tick(float deltaTime)
    {
        if(stateMachine.InputReader.isColorActing)
        {
            stateMachine.CanHeiser = true;   
        }
        else
        {
            stateMachine.CanHeiser = false;
        }

        if (!stateMachine.CanHeiser)
        {
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }

        //stateMachine.ForceReceiver.ResetVerticalVelocity();
        stateMachine.ForceReceiver.AddForce(Vector3.up * stateMachine.HoverForce * deltaTime);
        MoveHoverDirect(deltaTime);
    }

    public override void Exit()
    {
        stateMachine.CanHeiser = true;
        //Se apagan aqui las particulas
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
