using UnityEngine;

public class PlayerHeiserState : PlayerBaseState
{
    public PlayerHeiserState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    

    public override void Enter()
    {
        //stateMachine.ForceReceiver.ResetVerticalVelocity();
        stateMachine.CanHeiser = true;
        stateMachine.CanHeiser = false;
        //Si tuvieramos particulas se ponen aqui

    }

    public override void Tick(float deltaTime)
    {
        if (!stateMachine.InputReader.isHeiser)
        {
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }

        stateMachine.ForceReceiver.ResetVerticalVelocity();
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
