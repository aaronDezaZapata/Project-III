using UnityEngine;
using UnityEngine.AI;

public class EnemyChaseState : EnemyBaseState
{

    public EnemyChaseState(EnemyStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        stateMachine.agent.acceleration = stateMachine.MovementSpeed;
    }

    public override void Tick(float deltaTime)
    {

        //If is close enough
        if (Vector3.Distance(GameManager.Instance.GetPlayer().position, stateMachine.transform.position) < stateMachine.AttackRange)
        {
            stateMachine.SwitchState(typeof(EnemyAttackState));
            return;
        }

        if (Vector3.Distance(GameManager.Instance.GetPlayer().position, stateMachine.transform.position) < stateMachine.DetectionRange)
        {
            stateMachine.agent.SetDestination(GameManager.Instance.GetPlayer().position);
            return;
        }
        else
        {
            stateMachine.SwitchState(typeof(EnemyIdleState));
            return;
        }

       
    }

    public override void Exit()
    {
        
    }
}
