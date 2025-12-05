using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class PlayerBaseState : State
{
   protected PlayerStateMachine stateMachine;

   

    public PlayerBaseState(PlayerStateMachine stateMachine)
    {
        this.stateMachine = stateMachine;

    }
    
    protected void Move(Vector3 motion, float deltaTime)
    {
        stateMachine.Controller.Move((motion + stateMachine.ForceReceiver.Movement) * deltaTime);
    }
    
    protected void Move(float deltaTime)
    {
        Move(Vector3.zero, deltaTime);
    }
    
    
    protected void FaceTarget(Transform target)
    {
        if(target == null) { return; }

        Vector3 enemyDirection = (target.transform.position - stateMachine.transform.position);

        enemyDirection.y = 0f;

        stateMachine.transform.rotation = Quaternion.LookRotation(enemyDirection * stateMachine.RotationSpeed);
    }


    protected void FaceTargetInstant(EnemyStateMachine enemy)
    {

        if (enemy == null) { return; }

        Vector3 lookPos = enemy.transform.position - stateMachine.transform.position;
        lookPos.y = 0;
        Quaternion rotation = Quaternion.LookRotation(lookPos);
        stateMachine.transform.rotation = rotation;

    }



}
