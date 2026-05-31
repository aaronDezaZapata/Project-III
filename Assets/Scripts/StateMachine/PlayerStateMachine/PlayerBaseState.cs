using System.Collections;
using System.Collections.Generic;
using Unity.Cinemachine;
using UnityEngine;

public abstract class PlayerBaseState : State
{
    #region Variables

    protected PlayerStateMachine stateMachine;

    private Vector3 _currentMovementVelocity;
    private Vector3 _movementVelocitySmoothRef;
    
    private bool _isQuickStopping;
    
    private float _timeSinceLeftGround;
    private bool _wasGroundedLastFrame;
    
    private bool _doubleJumpAvailable = true;
    private bool _hasUsedDoubleJump;
    
    protected readonly int JumpTriggered = Animator.StringToHash("JumpTriggered");
    protected readonly int DoubleJumpTriggered = Animator.StringToHash("DoubleJumpTriggered");

    #endregion

    public PlayerBaseState(PlayerStateMachine stateMachine)
    {
        this.stateMachine = stateMachine;
    }

    #region Movement

    protected void Move(Vector3 motion, float deltaTime)
    {
        UpdateCoyoteTime(deltaTime);
        
        Vector3 horizontalMotion = new Vector3(motion.x, 0, motion.z);
        Vector3 verticalMotion = new Vector3(0, motion.y, 0);
        
        bool hasSideCollision = (stateMachine.Controller.collisionFlags & CollisionFlags.Sides) != 0;
        bool isTouchingWallInAir = hasSideCollision && !stateMachine.isGrounded;
        if (isTouchingWallInAir)
        {
            horizontalMotion = Vector3.zero;
            _currentMovementVelocity = Vector3.zero;
            _movementVelocitySmoothRef = Vector3.zero;
        }
        
        float directionChangeAngle = 0f;
        bool hasInput = horizontalMotion.magnitude > 0.01f;
        bool isMoving = _currentMovementVelocity.magnitude > 0.5f;
        
        if (hasInput && isMoving)
        {
            Vector3 currentDir = _currentMovementVelocity.normalized;
            Vector3 newDir = horizontalMotion.normalized;
            directionChangeAngle = Vector3.Angle(currentDir, newDir);
            
            if (directionChangeAngle > stateMachine.DirectionChangeThreshold && !_isQuickStopping)
            {
                _isQuickStopping = true;
            }
        }
        
        float smoothTime;
        
        if (_isQuickStopping)
        {
            smoothTime = stateMachine.QuickStopTime;
            
            if (_currentMovementVelocity.magnitude < stateMachine.QuickStopSpeedThreshold)
            {
                _isQuickStopping = false;
                _currentMovementVelocity = Vector3.zero;
                _movementVelocitySmoothRef = Vector3.zero;
            }
            
            horizontalMotion = Vector3.zero;
        }
        else if (hasInput)
        {
            smoothTime = stateMachine.AccelerationTime;
        }
        else
        {
            smoothTime = stateMachine.DecelerationTime;
        }

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
    
    #endregion

    #region Jump

    private void UpdateCoyoteTime(float deltaTime)
    {
        bool isGroundedNow = stateMachine.isGrounded;
        
        
        if (_wasGroundedLastFrame && !isGroundedNow)
        {
            _timeSinceLeftGround = 0f;
        }
        
        else if (!isGroundedNow)
        {
            _timeSinceLeftGround += deltaTime;
        }
        
        else
        {
            _timeSinceLeftGround = 0f;
            
            _hasUsedDoubleJump = false;
            _doubleJumpAvailable = true;
        }
        
        _wasGroundedLastFrame = isGroundedNow;
    }
    
    protected bool CanJump()
    {
        bool canFirstJump = stateMachine.isGrounded || _timeSinceLeftGround <= stateMachine.CoyoteTime;
        
        bool canDoubleJump = stateMachine.HasDoubleJump && !stateMachine.isGrounded && _doubleJumpAvailable && !_hasUsedDoubleJump;
        
        return canFirstJump || canDoubleJump;
    }

    public void ResetDoubleJump()
    {
        _timeSinceLeftGround = 0f;
        _hasUsedDoubleJump = false;
        _doubleJumpAvailable = true;
    }

    protected void Jump()
    {
        bool isFirstJump = stateMachine.isGrounded || _timeSinceLeftGround <= stateMachine.CoyoteTime;

        if (isFirstJump)
        {
            stateMachine.ForceReceiver.Jump(stateMachine.JumpForce);
            stateMachine.PlayerAudio?.PlayJump();
            
            _timeSinceLeftGround = stateMachine.CoyoteTime + 1f;
            
            stateMachine.Animator.SetTrigger(JumpTriggered);
        }
        else if (stateMachine.HasDoubleJump && _doubleJumpAvailable && !_hasUsedDoubleJump)
        {
            stateMachine.ForceReceiver.Jump(stateMachine.DoubleJumpForce);
            stateMachine.PlayerAudio?.PlayDoubleJump();

            _hasUsedDoubleJump = true;
            
            stateMachine.Animator.SetTrigger(DoubleJumpTriggered);
        }
    }

    #endregion
}
