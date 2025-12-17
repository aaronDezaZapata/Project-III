using UnityEngine;

public class EnemyIdleState : EnemyBaseState
{
    public EnemyIdleState(EnemyStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        
    }


    public override void Tick(float deltaTime)
    {
        if (Vector3.Distance(GameManager.Instance.GetPlayer().position, stateMachine.transform.position) < stateMachine.DetectionRange)
        {
            stateMachine.SwitchState(typeof(EnemyChaseState));
        }
    }



    public override void Exit()
    {

    }


}
