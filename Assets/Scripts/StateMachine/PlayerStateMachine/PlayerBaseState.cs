using System.Collections;
using System.Collections.Generic;
using Unity.Cinemachine;
using UnityEngine;

public abstract class PlayerBaseState : State
{
    protected PlayerStateMachine stateMachine;

    private Vector3 _currentMovementVelocity;
    private Vector3 _movementVelocitySmoothRef;
    
    private Vector3 _lastMovementDirection;
    private bool _isQuickStopping = false;
    private float _quickStopTimer = 0f;
    
    private float _timeSinceLeftGround = 0f;
    private bool _wasGroundedLastFrame = false;
    
    private bool _doubleJumpAvailable = true;
    private bool _hasUsedDoubleJump = false;
    
    protected readonly int JumpTriggered = Animator.StringToHash("JumpTriggered");
    protected readonly int DoubleJumpTriggered = Animator.StringToHash("DoubleJumpTriggered");
    

    public PlayerBaseState(PlayerStateMachine stateMachine)
    {
        this.stateMachine = stateMachine;
    }

    #region Movement

    protected void Move(Vector3 motion, float deltaTime)
    {
        // Actualizar coyote time
        UpdateCoyoteTime(deltaTime);
        
        Vector3 horizontalMotion = new Vector3(motion.x, 0, motion.z);
        Vector3 verticalMotion = new Vector3(0, motion.y, 0);

        // eliminar el input horizontal para que la velocidad no
        // se acumule contra la pared y bloquee la gravedad.
        bool hasSideCollision = (stateMachine.Controller.collisionFlags & CollisionFlags.Sides) != 0;
        bool isTouchingWallInAir = hasSideCollision && !stateMachine.isGrounded;
        if (isTouchingWallInAir)
        {
            horizontalMotion = Vector3.zero;
            _currentMovementVelocity = Vector3.zero;
            _movementVelocitySmoothRef = Vector3.zero;
        }

        // Detectar cambio brusco de dirección
        float directionChangeAngle = 0f;
        bool hasInput = horizontalMotion.magnitude > 0.01f;
        bool isMoving = _currentMovementVelocity.magnitude > 0.5f;
        
        if (hasInput && isMoving)
        {
            Vector3 currentDir = _currentMovementVelocity.normalized;
            Vector3 newDir = horizontalMotion.normalized;
            directionChangeAngle = Vector3.Angle(currentDir, newDir);
            
            // Si el ángulo es mayor a 90 grados, es un cambio brusco
            if (directionChangeAngle > stateMachine.DirectionChangeThreshold && !_isQuickStopping)
            {
                _isQuickStopping = true;
                _quickStopTimer = 0f;
            }
        }
        
        // Determinar el smooth time basado en el estado
        float smoothTime;
        
        if (_isQuickStopping)
        {
            // Durante el frenado rápido, usar un tiempo muy corto
            smoothTime = stateMachine.QuickStopTime;
            _quickStopTimer += deltaTime;
            
            // Si la velocidad es muy baja, salir del estado de frenado
            if (_currentMovementVelocity.magnitude < stateMachine.QuickStopSpeedThreshold)
            {
                _isQuickStopping = false;
                _currentMovementVelocity = Vector3.zero;
                _movementVelocitySmoothRef = Vector3.zero;
            }
            
            // Forzar el target a cero durante el frenado
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

        // Guardar la última dirección de movimiento
        if (_currentMovementVelocity.magnitude > 0.01f)
        {
            _lastMovementDirection = _currentMovementVelocity.normalized;
        }
        
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

            if (stateMachine.HasDoubleJump)
            {
                _doubleJumpAvailable = true;
                _hasUsedDoubleJump = false;
            }
            
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
