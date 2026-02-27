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
        Debug.Log("Entered PlayerDashAttackState");
        
        targetEnemy = FindNearestPaintedEnemy();
        
        if (targetEnemy == null)
        {
            Debug.LogWarning("No painted enemy found, returning to FreeLook");
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }
        
        dashDirection = (targetEnemy.position - stateMachine.transform.position).normalized;
        dashSpeed = stateMachine.DashAttackSpeed;
        hasHitTarget = false;
        dashTimer = 0f;
        
        FaceTarget(targetEnemy);
        
        stateMachine.ForceReceiver.SetUseGravity(false);

        Debug.Log($"Dashing towards {targetEnemy.name} at speed {dashSpeed}");
    }
    
    public override void Tick(float deltaTime)
    {
        dashTimer += deltaTime;

        // Si pasó mucho tiempo, cancelar el dash
        if (dashTimer > maxDashTime)
        {
            Debug.Log("Dash timeout, returning to FreeLook");
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
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
            Debug.Log("Target enemy disappeared");
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
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
    
    private Transform FindNearestPaintedEnemy()
    {
        if(GameManager.Instance.enemiesPainted.Count == 0) return null;
        List<PaintableEnemy> allPaintableEnemies = GameManager.Instance.enemiesPainted;
        
        Transform nearest = null;
        
        float minDistanceSqr = Mathf.Infinity; 
        Vector3 currentPos = stateMachine.transform.position;
        
        foreach (PaintableEnemy enemy in allPaintableEnemies)
        {
            if (enemy == null) continue;

            // Calculamos la distancia
            Vector3 dirToEnemy = enemy.transform.position - currentPos;
            float dSqrToTarget = dirToEnemy.sqrMagnitude;
            
            if (dSqrToTarget < minDistanceSqr)
            {
                minDistanceSqr = dSqrToTarget; // New Closest Enemy
                nearest = enemy.transform;     // Closest Enemy
            }
        }
        return nearest;
    }

    private void OnHitEnemy()
    {
        hasHitTarget = true;

        // Aplicar daño al enemigo
        EnemyStateMachine enemyStateMachine = targetEnemy.GetComponent<EnemyStateMachine>();
        if (enemyStateMachine != null)
        {
            // Causar daño al enemigo
            enemyStateMachine.GoToDeath(); // O usa tu sistema de daño preferido
            Debug.Log($"Damaged enemy: {targetEnemy.name}");
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
        stateMachine.SwitchState(typeof(PlayerFreeLookState));
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

        Debug.Log($"Applied knockback: {totalKnockback}");
    }
}
