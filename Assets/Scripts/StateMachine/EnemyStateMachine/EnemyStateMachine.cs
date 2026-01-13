using System;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Events;

public class EnemyStateMachine : StateMachine
{
    [field: SerializeField] public CharacterController Controller { get; private set; }
    [field: SerializeField] public float MovementSpeed { get; private set; } = 3f;
    [field: SerializeField] public float AccelerationTime { get; private set; } = 3f;
    [field: SerializeField] public float DecelerationTime { get; private set; } = 3f;
    [field: SerializeField] public float MovementAttackSpeed { get; private set; } = 20f;
    [field: SerializeField] public float RotationSpeed { get; private set; } = 3f;
    [field: SerializeField] public float AttackRange { get; private set; } = 2f;
    [field: SerializeField] public float DetectionRange { get; private set; } = 6f;
    [field: SerializeField] public SkinnedMeshRenderer Mat { get; set; }
    [field: SerializeField] public int Health { get; private set; } = 3;
    [field: SerializeField] public bool isGettingAttacked = false;
    [field: SerializeField] public NavMeshAgent agent { get; private set; }
    [field: SerializeField] public ForceReceiver ForceReceiver { get; private set; }


    //NonSerialized
    [NonSerialized] public float _sprayResetTimer = 0f;
    [NonSerialized] public float _sprayCooldown = 0.2f;
    [NonSerialized] public bool isBeingThrown = false; // Trackea si el enemigo fue lanzado por el jugador
    [NonSerialized] public float thrownVelocityMagnitude = 0f; // Magnitud de la velocidad al ser lanzado
    
    private Vector3 _currentMovementVelocity;
    private Vector3 _movementVelocitySmoothRef;

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

        // Colisión con obstáculo
        if (collision.gameObject.CompareTag("Obstacle"))
        {
            float velocity = GetCurrentVelocityMagnitude();
            
            if (velocity > 5f)
            {
                Debug.Log($"Enemigo golpeó obstáculo a {velocity:F2} m/s - Muerte");
                GoToDeath();
                return;
            }
        }

        // Colisión con objeto
        if (collision.gameObject.CompareTag("Object"))
        {
            if (collision.transform.TryGetComponent<Rigidbody>(out var rb))
            {
                if (rb.linearVelocity.magnitude > 5)
                {
                    Debug.Log($"Objeto golpeó enemigo a {rb.linearVelocity.magnitude:F2} m/s - Muerte");
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
