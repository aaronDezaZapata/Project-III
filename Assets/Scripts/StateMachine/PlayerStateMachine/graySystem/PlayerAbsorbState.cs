using System.Collections.Generic;
using UnityEngine;

// TODO: Remove
// Remove the hole script and its dependencies.
public class PlayerAbsorbState : PlayerBaseState
{
    private readonly int Vacuum = Animator.StringToHash("Vacuum");
    private const float CrossFadeDuration = 0.1f;
    private readonly int ShootEnemy = Animator.StringToHash("Shoot");

    // Objetos en proceso de absorción
    private List<AbsorbableObject> objectsBeingAbsorbed = new List<AbsorbableObject>();
    
    // Objeto grande que está siendo levantado
    private AbsorbableObject heldObject;
    
    // Control de estado
    private bool isAbsorbing;
    private bool isHoldingLarge;
    
    // Visual
    private ParticleSystem absorbParticles;
    
    public PlayerAbsorbState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        Debug.Log("Entered PlayerAbsorbState - Active Vacuum Mode");
        
        stateMachine.mainCamera.Priority = 10;
        stateMachine.Animator.CrossFadeInFixedTime(Vacuum, CrossFadeDuration);

        isAbsorbing = true;
        
        if (stateMachine.GrayAbsorbParticles != null)
        {
            absorbParticles = stateMachine.GrayAbsorbParticles;
            absorbParticles.Play();
        }
    }

    public override void Tick(float deltaTime)
    {
        // Si suelta el botón de absorción, salir del estado
        if (!stateMachine.InputReader.isColorActing)
        {
            // Si tenía un objeto LARGE, dispararlo antes de salir
            if (isHoldingLarge && heldObject != null)
            {
                ShootHeldObjectOnRelease();
            }
            
            stateMachine.SwitchState(typeof(PlayerRedState));
            return;
        }
        
        // Si presiona Aim, ir al estado de disparo
        if (stateMachine.InputReader.isAiming)
        {
            stateMachine.SwitchState(typeof(PlayerShootingState));
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
        
        MovePlayer(deltaTime);
        RotatePlayer(deltaTime);
    }

    public override void Exit()
    {
        
        if (absorbParticles != null)
        {
            absorbParticles.Stop();
        }
        
        foreach (var obj in objectsBeingAbsorbed)
        {
            if (obj != null)
            {
                obj.Release();
            }
        }
        objectsBeingAbsorbed.Clear();
        
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
        
        // Buscar objetos absorbibles
        Collider[] hits = Physics.OverlapSphere(
            origin + direction * stateMachine.GrayAbsorbRange * 0.5f,
            stateMachine.GrayAbsorbRange,
            stateMachine.AbsorbableLayer
        );
        
        foreach (Collider hit in hits)
        {
            Vector3 dirToObj = (hit.transform.position - origin).normalized;
            float angle = Vector3.Angle(direction, dirToObj);
            
            if (angle > stateMachine.GrayAbsorbAngle * 0.5f)
                continue;
            
            AbsorbableObject absorbable = hit.GetComponent<AbsorbableObject>();
            if (absorbable != null && !absorbable.isAbsorbed && !absorbable.isBeingAbsorbed)
            {
                StartAbsorbing(absorbable);
            }
        }
        
        // Buscar enemigos en su propia capa
        Collider[] enemyHits = Physics.OverlapSphere(
            origin + direction * stateMachine.GrayAbsorbRange * 0.5f,
            stateMachine.GrayAbsorbRange,
            stateMachine.AbsorbableLayer
        );
        
        foreach (Collider hit in enemyHits)
        {
            Vector3 dirToObj = (hit.transform.position - origin).normalized;
            float angle = Vector3.Angle(direction, dirToObj);
            
            if (angle > stateMachine.GrayAbsorbAngle * 0.5f)
                continue;
            
            EnemyScript enemy = hit.GetComponent<EnemyScript>();
            if (enemy != null)
            {
                AbsorbEnemy(enemy);
            }
        }
    }
    
    private void StartAbsorbing(AbsorbableObject obj)
    {
        if (objectsBeingAbsorbed.Count >= stateMachine.GrayMaxSimultaneousAbsorb)
            return;
        
        // Para objetos SMALL, verificar si hay espacio en la lista del StateMachine
        if (obj.size == AbsorbableObject.AbsorbableSize.Small)
        {
            if (stateMachine.absorbedObjects.Count >= PlayerStateMachine.MaxAbsorbedSmallObjects)
            {
                return;
            }
        }
        
        // Para objetos LARGE, verificar si ya tiene uno
        if (obj.size == AbsorbableObject.AbsorbableSize.Large && isHoldingLarge)
        {
            return;
        }
        
        obj.StartAbsorption();
        objectsBeingAbsorbed.Add(obj);
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
            
            Vector3 targetPos = stateMachine.transform.position + Vector3.up * 1.5f;
            
            float speed = stateMachine.GrayAbsorbSpeed / obj.weight;
            obj.transform.position = Vector3.MoveTowards(
                obj.transform.position,
                targetPos,
                speed * deltaTime
            );
            
            if (obj.size == AbsorbableObject.AbsorbableSize.Small)
            {
                obj.transform.localScale = Vector3.Lerp(
                    obj.transform.localScale,
                    Vector3.zero,
                    deltaTime * 2f
                );
            }
            
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
                // Añadir a la lista del StateMachine
                // stateMachine.TryAddAbsorbedObject(obj);
                break;
                
            case AbsorbableObject.AbsorbableSize.Large:
                if (heldObject != null)
                {
                    heldObject.Release();
                }
                
                heldObject = obj;
                obj.StartHolding();
                isHoldingLarge = true;
                break;
        }
    }
    
    private void AbsorbEnemy(EnemyScript enemy)
    {
        // Verificar si el enemigo ya tiene AbsorbableObject y ya está siendo absorbido
        AbsorbableObject existingAbsorbable = enemy.GetComponent<AbsorbableObject>();
        if (existingAbsorbable != null && (existingAbsorbable.isAbsorbed || existingAbsorbable.isBeingAbsorbed))
        {
            return; // Ya está siendo absorbido
        }
        
        enemy.Stun(true);
        
        AbsorbableObject enemyAbsorbable = existingAbsorbable;
        if (enemyAbsorbable == null)
        {
            enemyAbsorbable = enemy.gameObject.AddComponent<AbsorbableObject>();
            enemyAbsorbable.size = AbsorbableObject.AbsorbableSize.Small;
            enemyAbsorbable.weight = 2f;
            enemyAbsorbable.canBeProjectile = true;
            enemyAbsorbable.projectileDamage = 30f;
            enemyAbsorbable.projectileSpeed = 25f;
        }
        
        // Asegurar que el enemigo tenga Rigidbody para poder ser disparado
        Rigidbody rb = enemy.GetComponent<Rigidbody>();
        if (rb == null)
        {
            rb = enemy.gameObject.AddComponent<Rigidbody>();
            rb.useGravity = true;
            rb.isKinematic = false;
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
        
        Vector3 targetPos = stateMachine.transform.position 
            + Vector3.up * stateMachine.GrayHoldHeight
            + stateMachine.transform.forward * stateMachine.GrayHoldDistance;
        
        heldObject.transform.position = Vector3.Lerp(
            heldObject.transform.position,
            targetPos,
            deltaTime * 10f
        );
        
        heldObject.transform.rotation = Quaternion.Slerp(
            heldObject.transform.rotation,
            stateMachine.transform.rotation,
            deltaTime * 5f
        );
    }
    
    #endregion

    #region Shooting Large Objects
    
    private void ShootHeldObjectOnRelease()
    {
        if (heldObject == null) return;
        
        Vector3 shootDirection = Camera.main.transform.forward;
        shootDirection.Normalize();
        
        stateMachine.Animator.CrossFadeInFixedTime(ShootEnemy, CrossFadeDuration);
        
        heldObject.ShootAsProjectile(shootDirection, stateMachine.GrayProjectileSpeedMultiplier);
        
        heldObject = null;
        isHoldingLarge = false;
    }
    
    #endregion

    #region Movement
    
    private void MovePlayer(float deltaTime)
    {
        Vector2 input = stateMachine.InputReader.MoveVector;
        
        if (input.magnitude < 0.1f) return;
        
        Vector3 movement = CalculateMovement();
        
        float speedMultiplier = isHoldingLarge ? 0.6f : 1f;
        
        Move(movement * stateMachine.AbsorbingMovementSpeed * speedMultiplier, deltaTime);
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
