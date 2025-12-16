using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class PlayerBaseState : State
{
   protected PlayerStateMachine stateMachine;

    private Vector3 _currentMovementVelocity;
    private Vector3 _movementVelocitySmoothRef;
    

    public PlayerBaseState(PlayerStateMachine stateMachine)
    {
        this.stateMachine = stateMachine;
    }

    #region Movement

    protected void Move(Vector3 motion, float deltaTime)
    {
        
        Vector3 horizontalMotion = new Vector3(motion.x, 0, motion.z);
        Vector3 verticalMotion = new Vector3(0, motion.y, 0);

        
        float smoothTime = horizontalMotion.magnitude > 0.01f 
            ? stateMachine.AccelerationTime
            : stateMachine.DecelerationTime;

        _currentMovementVelocity = Vector3.SmoothDamp(
            _currentMovementVelocity,
            horizontalMotion,
            ref _movementVelocitySmoothRef,
            smoothTime
        );

        
        Vector3 finalMovement = _currentMovementVelocity + verticalMotion + stateMachine.ForceReceiver.Movement;
        
        CollisionFlags flags = stateMachine.Controller.Move(finalMovement * deltaTime);

        if ((flags & CollisionFlags.Above) != 0)
        {
            stateMachine.ForceReceiver.ResetVerticalVelocity();
        }
    }
    
    protected void MoveNoInertia(Vector3 motion, float deltaTime)
    {
        _currentMovementVelocity = motion;
        _movementVelocitySmoothRef = Vector3.zero;

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

    #endregion

    #region Jump

    protected void Jump()
    {
        if (!stateMachine.Controller.isGrounded) return;
        
        stateMachine.ForceReceiver.Jump(stateMachine.JumpForce);
    }

    #endregion
}
