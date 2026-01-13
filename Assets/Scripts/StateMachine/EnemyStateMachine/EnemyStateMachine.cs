using System;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Events;

public class EnemyStateMachine : StateMachine
{
    [field: SerializeField] public CharacterController Controller { get; private set; }
    [field: SerializeField] public float MovementSpeed { get; private set; } = 3f;
    [field: SerializeField] public float MovementAttackSpeed { get; private set; } = 20f;
    [field: SerializeField] public float RotationSpeed { get; private set; } = 3f;
    [field: SerializeField] public float AttackRange { get; private set; } = 2f;
    [field: SerializeField] public float DetectionRange { get; private set; } = 6f;
    [field: SerializeField] public int Health { get; private set; } = 3;
    [field: SerializeField] public bool isGettingAttacked = false;
    [field: SerializeField] public NavMeshAgent agent { get; private set; }


    //NonSerialized
    [NonSerialized] public float _sprayResetTimer = 0f;
    [NonSerialized] public float _sprayCooldown = 0.2f;
    [NonSerialized] public bool isBeingThrown = false;
    [NonSerialized] public float thrownVelocityMagnitude = 0f;

    void Awake()
    {
        //Añade todos los states aqui antes de hacer switch
        AddState(new EnemyIdleState(this));
        AddState(new EnemyChaseState(this));
        AddState(new EnemyAttackState(this));
        AddState(new EnemyStunnedState(this));
        AddState(new EnemyInflatableState(this));
        AddState(new EnemyDeathState(this));
    }


    private void Start()
    {
       
        SwitchState(typeof(EnemyIdleState));
    }

    public void GoToDeath()
    {
        float velocityDeath = 5f;
        EnemyDeathState deathState = states[typeof(EnemyDeathState)] as EnemyDeathState;

        if (deathState != null)
        {
            
            deathState.ConfigureDeath(velocityDeath); // Velocidad

            
            SwitchState(typeof(EnemyDeathState));
        }
        else
        {
            Debug.LogError("No has añadido EnemyDeathState en el Awake");
        }
    }


    void OnParticleCollision(GameObject other)
    {
        
        if (other.CompareTag("WaterJet"))
        { 
            isGettingAttacked = true;

            _sprayResetTimer = _sprayCooldown;

            if (currentState.GetType() != typeof(EnemyInflatableState))
            {
                SwitchState(typeof(EnemyInflatableState));
                return;
            }
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        // Colisión con otro enemigo
        if(collision.gameObject.CompareTag("Enemy"))
        {
            EnemyStateMachine otherEnemy = collision.gameObject.GetComponent<EnemyStateMachine>();
            if (otherEnemy == null) return;

            bool thisEnemyThrown = isBeingThrown;
            bool otherEnemyThrown = otherEnemy.isBeingThrown;

            // Velocidades
            float thisVelocity = GetCurrentVelocityMagnitude();
            float otherVelocity = otherEnemy.GetCurrentVelocityMagnitude();

            // Si alguno de los dos fue lanzado y va rápido, ambos mueren
            if ((thisEnemyThrown && thisVelocity > 5f) || (otherEnemyThrown && otherVelocity > 5f))
            {
                Debug.Log($"Colisión mortal entre enemigos - Este: {thisVelocity:F2} m/s (lanzado: {thisEnemyThrown}), Otro: {otherVelocity:F2} m/s (lanzado: {otherEnemyThrown})");
                otherEnemy.GoToDeath();
                GoToDeath();
                return;
            }
            
            // Lógica original: si alguno va muy rápido (sin importar si fue lanzado), ambos mueren
            if (thisVelocity > 5f || otherVelocity > 5f)
            {
                Debug.Log($"Colisión a alta velocidad entre enemigos - Este: {thisVelocity:F2} m/s, Otro: {otherVelocity:F2} m/s");
                otherEnemy.GoToDeath();
                GoToDeath();
                return;
            }
        }

        if (collision.gameObject.CompareTag("Obstacle"))
        {
            if (Controller.velocity.magnitude > 5f)
            {
                //Death
                GoToDeath();
                return;
            }
        }

        if (collision.gameObject.CompareTag("Object"))
        {
            if (collision.transform.TryGetComponent<Rigidbody>(out var cc))
            {
                if (cc.linearVelocity.magnitude > 5)
                {
                    //Death
                    GoToDeath();
                    return;
                }
            }
        }
    }
    
    /// <summary>
    /// Obtiene la velocidad actual del enemigo, considerando CharacterController o Rigidbody
    /// </summary>
    private float GetCurrentVelocityMagnitude()
    {
        // Si está siendo lanzado, usar la velocidad almacenada
        if (isBeingThrown && thrownVelocityMagnitude > 0)
        {
            return thrownVelocityMagnitude;
        }

        // Intentar obtener de Rigidbody
        Rigidbody rb = GetComponent<Rigidbody>();
        if (rb != null && !rb.isKinematic)
        {
            return rb.linearVelocity.magnitude;
        }

        // Intentar obtener de CharacterController
        if (Controller != null && Controller.enabled)
        {
            return Controller.velocity.magnitude;
        }

        return 0f;
    }
    
    /// <summary>
    /// Marca al enemigo como lanzado con una velocidad específica
    /// </summary>
    public void MarkAsThrown(float velocityMagnitude)
    {
        isBeingThrown = true;
        thrownVelocityMagnitude = velocityMagnitude;
        Debug.Log($"Enemigo marcado como lanzado con velocidad {velocityMagnitude:F2} m/s");
    }

    /// <summary>
    /// Desmarca al enemigo como lanzado (llamar cuando toca el suelo o se detiene)
    /// </summary>
    public void UnmarkAsThrown()
    {
        isBeingThrown = false;
        thrownVelocityMagnitude = 0f;
    }
}
