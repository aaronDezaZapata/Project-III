using UnityEngine;

public class EnemyIdleState : EnemyBaseState
{
    private Vector3 _currentMovementVelocity;
    private Vector3 _movementVelocitySmoothRef;
    public EnemyIdleState(EnemyStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        
    }


    public override void Tick(float deltaTime)
    {
        /*if (Vector3.Distance(GameManager.Instance.GetPlayer().position, stateMachine.transform.position) < stateMachine.DetectionRange)
        {
            stateMachine.SwitchState(typeof(EnemyChaseState));
        }*/
        
        stateMachine.ForceReceiver.ForceMovement();
    }



    public override void Exit()
    {

    }
}
