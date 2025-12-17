using UnityEngine;

public class EnemyAttackState : EnemyBaseState
{
    float timeToAttack = 1f;
    float currentTime = 0;
    public EnemyAttackState(EnemyStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        currentTime = timeToAttack;
    }



    public override void Tick(float deltaTime)
    {
        stateMachine.agent.isStopped = true;
        if (Vector3.Distance(GameManager.Instance.GetPlayer().position, stateMachine.transform.position) < stateMachine.AttackRange)
        {
            currentTime -= Time.deltaTime;
        }
        else
        {
            stateMachine.SwitchState(typeof(EnemyChaseState));
            return;
        }

        if(currentTime <= 0f)
        {
            GameManager.Instance.GetPlayer().GetComponent<Health>().DealDamage(20);
            stateMachine.SwitchState(typeof(EnemyChaseState));
            return;
        }
    }

    public override void Exit()
    {

    }
}
