using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// Estado que maneja la mecánica de aspiradora (gris).
/// Absorbe objetos y enemigos, los almacena y los lanza como proyectiles.
/// </summary>
public class PlayerGrayState : PlayerBaseState
{
    // Objetos en proceso de absorción
    private List<AbsorbableObject> objectsBeingAbsorbed = new List<AbsorbableObject>();
    
    // Objeto grande que está siendo levantado
    private AbsorbableObject heldObject;
    
    // Inventario de objetos absorbidos (pequeños/medianos)
    private List<AbsorbableObject> absorbedObjects = new List<AbsorbableObject>();
    
    // Control de estado
    private bool isAbsorbing;
    private bool isHoldingLarge;
    private int maxStoredObjects = 5;
    
    // Visual
    private ParticleSystem absorbParticles;
    
    public PlayerGrayState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        Debug.Log("Entered PlayerGrayState - Vacuum Mode");
        
        isAbsorbing = true;
        
        // Inicializar sistema de partículas si existe
        if (stateMachine.GrayAbsorbParticles != null)
        {
            absorbParticles = stateMachine.GrayAbsorbParticles;
            absorbParticles.Play();
        }
        
        stateMachine.InputReader.JumpEvent += OnShoot;
    }

    public override void Tick(float deltaTime)
    {
        // Si suelta el botón gris, salir del estado
        if (!stateMachine.InputReader.isGray)
        {
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }
        
        if (isAbsorbing)
        {
            DetectAndAbsorbObjects(deltaTime);
            UpdateAbsorption(deltaTime);
        }
        
        if (isHoldingLarge)
        {
            UpdateHeldObject(deltaTime);
        }
        
        // Permitir movimiento mientras absorbe
        MovePlayer(deltaTime);
        RotatePlayer(deltaTime);
    }

    public override void Exit()
    {
        Debug.Log("Exiting PlayerGrayState");
        
        stateMachine.InputReader.JumpEvent -= OnShoot;
        
        // Detener partículas
        if (absorbParticles != null)
        {
            absorbParticles.Stop();
        }
        
        // Limpiar objetos en proceso
        foreach (var obj in objectsBeingAbsorbed)
        {
            if (obj != null)
            {
                obj.Release();
            }
        }
        objectsBeingAbsorbed.Clear();
        
        // Soltar objeto grande si lo tiene
        if (heldObject != null)
        {
            heldObject.Release();
            heldObject = null;
        }
        
        isAbsorbing = false;
        isHoldingLarge = false;
    }

    #region Detection & Absorption
    
    private void DetectAndAbsorbObjects(float deltaTime)
    {
        Vector3 origin = stateMachine.transform.position + Vector3.up;
        Vector3 direction = stateMachine.transform.forward;
        
        // Buscar objetos absorbibles en un cono frontal
        Collider[] hits = Physics.OverlapSphere(
            origin + direction * stateMachine.GrayAbsorbRange * 0.5f,
            stateMachine.GrayAbsorbRange,
            stateMachine.AbsorbableLayer
        );
        
        foreach (Collider hit in hits)
        {
            // Verificar que esté en el cono de absorción
            Vector3 dirToObj = (hit.transform.position - origin).normalized;
            float angle = Vector3.Angle(direction, dirToObj);
            
            if (angle > stateMachine.GrayAbsorbAngle * 0.5f)
                continue;
            
            // Intentar absorber
            AbsorbableObject absorbable = hit.GetComponent<AbsorbableObject>();
            if (absorbable != null && !absorbable.isAbsorbed && !absorbable.isBeingAbsorbed)
            {
                StartAbsorbing(absorbable);
            }
            
            // También detectar enemigos
            EnemyScript enemy = hit.GetComponent<EnemyScript>();
            if (enemy != null)
            {
                AbsorbEnemy(enemy);
            }
        }
    }
    
    private void StartAbsorbing(AbsorbableObject obj)
    {
        // Si ya está absorbiendo el máximo, no absorber más
        if (objectsBeingAbsorbed.Count >= stateMachine.GrayMaxSimultaneousAbsorb)
            return;
        
        obj.StartAbsorption();
        objectsBeingAbsorbed.Add(obj);
        
        Debug.Log($"Absorbiendo: {obj.name} ({obj.size})");
    }
    
    private void UpdateAbsorption(float deltaTime)
    {
        for (int i = objectsBeingAbsorbed.Count - 1; i >= 0; i--)
        {
            AbsorbableObject obj = objectsBeingAbsorbed[i];
            
            if (obj == null)
            {
                objectsBeingAbsorbed.RemoveAt(i);
                continue;
            }
            
            // Mover objeto hacia el jugador
            Vector3 targetPos = stateMachine.transform.position + Vector3.up * 1.5f;
            
            float speed = stateMachine.GrayAbsorbSpeed / obj.weight;
            obj.transform.position = Vector3.MoveTowards(
                obj.transform.position,
                targetPos,
                speed * deltaTime
            );
            
            // Reducir tamaño mientras se absorbe (para objetos pequeños)
            if (obj.size == AbsorbableObject.AbsorbableSize.Small)
            {
                obj.transform.localScale = Vector3.Lerp(
                    obj.transform.localScale,
                    Vector3.zero,
                    deltaTime * 2f
                );
            }
            
            // Verificar si llegó al jugador
            float distance = Vector3.Distance(obj.transform.position, targetPos);
            
            if (distance < 0.3f)
            {
                CompleteAbsorption(obj);
                objectsBeingAbsorbed.RemoveAt(i);
            }
        }
    }
    
    private void CompleteAbsorption(AbsorbableObject obj)
    {
        obj.CompleteAbsorption();
        
        switch (obj.size)
        {
            case AbsorbableObject.AbsorbableSize.Small:
                // Objetos pequeños se guardan en inventario
                if (absorbedObjects.Count < maxStoredObjects)
                {
                    absorbedObjects.Add(obj);
                    Debug.Log($"Objeto absorbido. Total: {absorbedObjects.Count}/{maxStoredObjects}");
                }
                else
                {
                    // Inventario lleno, destruir el más antiguo
                    AbsorbableObject oldest = absorbedObjects[0];
                    absorbedObjects.RemoveAt(0);
                    Object.Destroy(oldest.gameObject);
                    absorbedObjects.Add(obj);
                }
                break;
                
            case AbsorbableObject.AbsorbableSize.Medium:
                // Objetos medianos se guardan pero son visibles
                if (absorbedObjects.Count < maxStoredObjects)
                {
                    absorbedObjects.Add(obj);
                    PositionStoredObject(obj, absorbedObjects.Count - 1);
                }
                break;
                
            case AbsorbableObject.AbsorbableSize.Large:
                // Objetos grandes se levantan y se sostienen
                if (heldObject != null)
                {
                    heldObject.Release();
                }
                
                heldObject = obj;
                obj.StartHolding();
                isHoldingLarge = true;
                Debug.Log($"Levantando objeto grande: {obj.name}");
                break;
        }
    }
    
    private void AbsorbEnemy(EnemyScript enemy)
    {
        // Aturdir y absorber al enemigo
        enemy.Stun(true);
        
        // Crear un AbsorbableObject temporal para el enemigo
        AbsorbableObject enemyAbsorbable = enemy.GetComponent<AbsorbableObject>();
        if (enemyAbsorbable == null)
        {
            enemyAbsorbable = enemy.gameObject.AddComponent<AbsorbableObject>();
            enemyAbsorbable.size = AbsorbableObject.AbsorbableSize.Medium;
            enemyAbsorbable.weight = 2f;
            enemyAbsorbable.canBeProjectile = true;
            enemyAbsorbable.projectileDamage = 30f;
        }
        
        StartAbsorbing(enemyAbsorbable);
    }
    
    #endregion

    #region Hold Large Object
    
    private void UpdateHeldObject(float deltaTime)
    {
        if (heldObject == null)
        {
            isHoldingLarge = false;
            return;
        }
        
        // Posicionar objeto grande frente al jugador
        Vector3 targetPos = stateMachine.transform.position 
            + Vector3.up * stateMachine.GrayHoldHeight
            + stateMachine.transform.forward * stateMachine.GrayHoldDistance;
        
        heldObject.transform.position = Vector3.Lerp(
            heldObject.transform.position,
            targetPos,
            deltaTime * 10f
        );
        
        // Rotar para mirar al jugador
        heldObject.transform.rotation = Quaternion.Slerp(
            heldObject.transform.rotation,
            stateMachine.transform.rotation,
            deltaTime * 5f
        );
    }
    
    #endregion

    #region Shooting/Launching
    
    private void OnShoot()
    {
        // Si tiene objeto grande, lanzarlo
        if (isHoldingLarge && heldObject != null)
        {
            ShootHeldObject();
            return;
        }
        
        // Si tiene objetos absorbidos, lanzar uno
        if (absorbedObjects.Count > 0)
        {
            ShootStoredObject();
        }
    }
    
    private void ShootHeldObject()
    {
        if (heldObject == null) return;
        
        Vector3 shootDirection = stateMachine.transform.forward + Vector3.up * 0.2f;
        shootDirection.Normalize();
        
        heldObject.ConvertToProjectile(shootDirection, stateMachine.GrayProjectileSpeedMultiplier);
        
        Debug.Log($"Lanzado objeto grande: {heldObject.name}");
        
        heldObject = null;
        isHoldingLarge = false;
    }
    
    private void ShootStoredObject()
    {
        if (absorbedObjects.Count == 0) return;
        
        // Lanzar el último objeto absorbido
        AbsorbableObject obj = absorbedObjects[absorbedObjects.Count - 1];
        absorbedObjects.RemoveAt(absorbedObjects.Count - 1);
        
        if (obj == null) return;
        
        // Posicionar objeto frente al jugador
        obj.transform.position = stateMachine.transform.position 
            + Vector3.up * 1.5f 
            + stateMachine.transform.forward * 1f;
        
        Vector3 shootDirection = stateMachine.transform.forward + Vector3.up * 0.2f;
        shootDirection.Normalize();
        
        obj.ConvertToProjectile(shootDirection, stateMachine.GrayProjectileSpeedMultiplier);
        
        Debug.Log($"Lanzado proyectil: {obj.name}. Restantes: {absorbedObjects.Count}");
    }
    
    #endregion

    #region Visual Helpers
    
    private void PositionStoredObject(AbsorbableObject obj, int index)
    {
        // Posicionar objetos medianos orbitando al jugador
        float angle = (360f / maxStoredObjects) * index;
        float radius = 1.5f;
        
        Vector3 offset = new Vector3(
            Mathf.Cos(angle * Mathf.Deg2Rad) * radius,
            1f + index * 0.3f,
            Mathf.Sin(angle * Mathf.Deg2Rad) * radius
        );
        
        obj.transform.position = stateMachine.transform.position + offset;
        obj.transform.localScale = Vector3.one * 0.5f; // Reducir tamaño
    }
    
    #endregion

    #region Movement
    
    private void MovePlayer(float deltaTime)
    {
        Vector2 input = stateMachine.InputReader.MoveVector;
        
        if (input.magnitude < 0.1f) return;
        
        Vector3 movement = CalculateMovement();
        
        // Moverse más lento si está sosteniendo algo grande
        float speedMultiplier = isHoldingLarge ? 0.6f : 1f;
        
        Move(movement * stateMachine.FreeLookMovementSpeed * speedMultiplier, deltaTime);
    }
    
    private void RotatePlayer(float deltaTime)
    {
        Vector2 input = stateMachine.InputReader.MoveVector;
        
        if (input.magnitude < 0.1f) return;
        
        Vector3 movement = CalculateMovement();
        
        if (movement.sqrMagnitude > 0.01f)
        {
            Quaternion targetRotation = Quaternion.LookRotation(movement);
            stateMachine.transform.rotation = Quaternion.Slerp(
                stateMachine.transform.rotation,
                targetRotation,
                stateMachine.RotationSpeed * deltaTime
            );
        }
    }
    
    private Vector3 CalculateMovement()
    {
        Vector3 forward = Camera.main.transform.forward;
        Vector3 right = Camera.main.transform.right;

        forward.y = 0f;
        right.y = 0f;

        forward.Normalize();
        right.Normalize();

        Vector2 input = stateMachine.InputReader.MoveVector;
        return forward * input.y + right * input.x;
    }
    
    #endregion
}
