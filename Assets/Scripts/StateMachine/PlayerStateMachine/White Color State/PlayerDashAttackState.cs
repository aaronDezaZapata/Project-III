using System.Collections.Generic;
using UnityEngine;

public class PlayerDashAttackState : PlayerBaseState
{
    private Transform targetEnemy;
    private Vector3 dashDirection;
    private float dashSpeed;
    private bool hasHitTarget = false;
    private float dashTimer = 0f;
    private float maxDashTime = 999f;
    
    public PlayerDashAttackState(PlayerStateMachine stateMachine) : base(stateMachine)
    { }

    public override void Enter()
    {
        targetEnemy = FindNearestPaintedTarget();

        if (targetEnemy == null)
        {
            stateMachine.ReturnToMainState();
            return;
        }

        dashDirection = (targetEnemy.position - stateMachine.transform.position).normalized;
        dashSpeed = stateMachine.DashAttackSpeed;
        hasHitTarget = false;
        dashTimer = 0f;

        FaceTarget(targetEnemy);

        stateMachine.ForceReceiver.SetUseGravity(false);
        stateMachine.PlayerAudio?.PlayTpTravel();

    }

    public override void Tick(float deltaTime)
    {
        dashTimer += deltaTime;

        // Si pasó mucho tiempo, cancelar el dash
        if (dashTimer > maxDashTime)
        {
            stateMachine.ReturnToMainState();
            return;
        }

        if (hasHitTarget)
        {
            // El rebote se maneja en Exit
            return;
        }

        // Si el enemigo murió o desapareció, cancelar
        if (targetEnemy == null || !targetEnemy.gameObject.activeInHierarchy)
        {
            stateMachine.ReturnToMainState();
            return;
        }

        // Actualizar dirección hacia el enemigo (para seguimiento)
        Vector3 currentDirection = (targetEnemy.position - stateMachine.transform.position).normalized;
        dashDirection = Vector3.Lerp(dashDirection, currentDirection, deltaTime * 5f);

        // Mover al jugador
        Vector3 movement = dashDirection * dashSpeed;
        stateMachine.Controller.Move(movement * deltaTime);

        // Verificar si estamos cerca del enemigo
        float distanceToEnemy = Vector3.Distance(stateMachine.transform.position, targetEnemy.position);
        
        if (distanceToEnemy < stateMachine.DashAttackCollisionRadius)
        {
            OnHitEnemy();
        }
    }
    
    public override void Exit()
    {
        // Reactivar gravedad
        stateMachine.ForceReceiver.SetUseGravity(true);

        if (hasHitTarget)
        {
            // Aplicar impulso de rebote
            ApplyKnockback();
        }
    }
    
    private Transform FindNearestPaintedTarget()
    {
        Transform currentPaintBeacon = GameManager.Instance.paintBeacon.transform;
        
        if (currentPaintBeacon != null)
        {
            return currentPaintBeacon;
        }
        return null;
    }

    private void OnHitEnemy()
    {
        hasHitTarget = true;

        stateMachine.PlayerAudio?.PlayTpImpact();

        // Aplicar daño al enemigo
        EnemyStateMachine enemyStateMachine = targetEnemy.GetComponent<EnemyStateMachine>();
        if (enemyStateMachine != null)
        {
            // Causar daño al enemigo
            enemyStateMachine.GoToDeath(); // O usa tu sistema de daño preferido
        }

        // Limpiar la pintura del enemigo
        PaintableEnemy paintable = targetEnemy.GetComponent<PaintableEnemy>();
        if (paintable != null)
        {
            paintable.ForceClearPaint();
        }

        // Efecto de cámara (shake)
        stateMachine.StartCameraShake(0.2f);

        // Cambiar inmediatamente de estado para aplicar el knockback
        stateMachine.ReturnToMainState();
    }
    
    private void ApplyKnockback()
    {
        // Calcular dirección opuesta al enemigo
        Vector3 knockbackDirection = (stateMachine.transform.position - targetEnemy.position).normalized;
        
        // Componente horizontal
        Vector3 horizontalKnockback = new Vector3(knockbackDirection.x, 0f, knockbackDirection.z).normalized;
        horizontalKnockback *= stateMachine.DashAttackKnockbackForce;
        
        // Componente vertical
        Vector3 verticalKnockback = Vector3.up * stateMachine.DashAttackVerticalKnockback;
        
        // Aplicar impulso total
        Vector3 totalKnockback = horizontalKnockback + verticalKnockback;
        stateMachine.ForceReceiver.AddForce(totalKnockback);
    }
}
