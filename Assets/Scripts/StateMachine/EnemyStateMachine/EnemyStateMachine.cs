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
    [field: SerializeField] public SkinnedMeshRenderer Mat { get; set; }
    [field: SerializeField] public int Health { get; private set; } = 3;
    [field: SerializeField] public bool isGettingAttacked = false;
    [field: SerializeField] public NavMeshAgent agent { get; private set; }
    
    [field: SerializeField] public ForceReceiver ForceReceiver;


    //NonSerialized
    [NonSerialized] public float _sprayResetTimer = 0f;
    [NonSerialized] public float _sprayCooldown = 0.2f;
    [NonSerialized] public bool isBeingThrown = false; // Trackea si el enemigo fue lanzado por el jugador
    [NonSerialized] public float thrownVelocityMagnitude = 0f; // Magnitud de la velocidad al ser lanzado

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

    /// <summary>
    /// OnControllerColliderHit se llama cuando el CharacterController choca con algo
    /// Este es el método correcto para detectar colisiones de CharacterControllers
    /// </summary>
    private void OnControllerColliderHit(ControllerColliderHit hit)
    {
        if (isBeingThrown)
        {
            // Colisión con otro enemigo (CharacterController)
            if (hit.gameObject.CompareTag("Enemy"))
            {
                // Buscar EnemyStateMachine en el objeto golpeado, en sus hijos o en su padre
                EnemyStateMachine otherEnemy = hit.gameObject.GetComponent<EnemyStateMachine>();
            
                // Si no está en el objeto golpeado, buscar en el padre
                if (otherEnemy == null)
                {
                    otherEnemy = hit.gameObject.GetComponentInParent<EnemyStateMachine>();
                }
            
                // Si aún no lo encuentra, buscar en los hijos
                if (otherEnemy == null)
                {
                    otherEnemy = hit.gameObject.GetComponentInChildren<EnemyStateMachine>();
                }
            
                if (otherEnemy == null)
                {
                    Debug.LogWarning($"[OnControllerColliderHit] Objeto con tag 'Enemy' pero sin EnemyStateMachine: {hit.gameObject.name}");
                    return;
                }

                bool thisEnemyThrown = isBeingThrown;
                bool otherEnemyThrown = otherEnemy.isBeingThrown;

                // Velocidades
                float thisVelocity = GetCurrentVelocityMagnitude();
                float otherVelocity = otherEnemy.GetCurrentVelocityMagnitude();

                // Si alguno de los dos fue lanzado y va rápido, ambos mueren
                if (thisEnemyThrown || otherEnemyThrown)
                {
                    otherEnemy.GoToDeath();
                    GoToDeath();
                    return;
                }
            
                /*// Lógica original: si alguno va muy rápido (sin importar si fue lanzado), ambos mueren
                if (thisVelocity > 5f || otherVelocity > 5f)
                {
                    otherEnemy.GoToDeath();
                    GoToDeath();
                    return;
                }*/
            
                // Debug.Log($"[OnControllerColliderHit] Colisión entre enemigos sin suficiente velocidad - Este: {thisVelocity:F2} m/s, Otro: {otherVelocity:F2} m/s");
            }
            
            Debug.Log("Enemy Death hitting nothing!");
            GoToDeath();
            return;
        }

        // Colisión con obstáculo
        if (hit.gameObject.CompareTag("Obstacle"))
        {
            float velocity = GetCurrentVelocityMagnitude();
            
            if (velocity > 5f)
            {
                Debug.Log($"[OnControllerColliderHit] Enemigo golpeó obstáculo a {velocity:F2} m/s - Muerte");
                GoToDeath();
            }
        }
    }

    /// <summary>
    /// OnCollisionEnter para Rigidbodies (objetos dinámicos)
    /// </summary>
    private void OnCollisionEnter(Collision collision)
    {
        // Colisión con otro enemigo (si tiene Rigidbody)
        if(collision.gameObject.CompareTag("Enemy"))
        {
            // Buscar EnemyStateMachine en el objeto golpeado, en sus hijos o en su padre
            EnemyStateMachine otherEnemy = collision.gameObject.GetComponent<EnemyStateMachine>();
            
            // Si no está en el objeto golpeado, buscar en el padre
            if (otherEnemy == null)
            {
                otherEnemy = collision.gameObject.GetComponentInParent<EnemyStateMachine>();
            }
            
            // Si aún no lo encuentra, buscar en los hijos
            if (otherEnemy == null)
            {
                otherEnemy = collision.gameObject.GetComponentInChildren<EnemyStateMachine>();
            }
            
            if (otherEnemy == null)
            {
                Debug.LogWarning($"[OnCollisionEnter] Objeto con tag 'Enemy' pero sin EnemyStateMachine: {collision.gameObject.name}");
                return;
            }

            bool thisEnemyThrown = isBeingThrown;
            bool otherEnemyThrown = otherEnemy.isBeingThrown;

            // Velocidades
            float thisVelocity = GetCurrentVelocityMagnitude();
            float otherVelocity = otherEnemy.GetCurrentVelocityMagnitude();

            // Si alguno de los dos fue lanzado y va rápido, ambos mueren
            if (thisEnemyThrown || otherEnemyThrown)
            {
                Debug.Log($"[OnCollisionEnter] Colisión mortal entre enemigos - Este: {thisVelocity:F2} m/s (lanzado: {thisEnemyThrown}), Otro: {otherVelocity:F2} m/s (lanzado: {otherEnemyThrown})");
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
                Debug.Log($"[OnCollisionEnter] Enemigo golpeó obstáculo a {velocity:F2} m/s - Muerte");
                GoToDeath();
                return;
            }
        }

        // Colisión con objeto con Rigidbody
        if (collision.gameObject.CompareTag("Object"))
        {
            if (collision.transform.TryGetComponent<Rigidbody>(out var rb))
            {
                isGettingAttacked = true;

                _sprayResetTimer = _sprayCooldown;

                if (currentState.GetType() != typeof(EnemyInflatableState))
                {
                    SwitchState(typeof(EnemyInflatableState));
                    return;
                }

                if (rb.linearVelocity.magnitude > 5)
                {
                    Debug.Log($"[OnCollisionEnter] Objeto golpeó enemigo a {rb.linearVelocity.magnitude:F2} m/s - Muerte");
                    GoToDeath();
                   
                    return;
                }
            }
        }
        
        Debug.Log("Enemy Death hitting nothing!");
        GoToDeath();
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

    // Estado original de los componentes de física (guardado al desactivar)
    private bool _originalControllerEnabled;
    private bool _originalAgentEnabled;
    private bool _originalForceReceiverEnabled;
    private Collider _capturedCollider;

    public void DisablePhysics()
    {
        if (Controller != null)
        {
            _originalControllerEnabled = Controller.enabled;
            Controller.enabled = false;
        }

        if (ForceReceiver != null)
        {
            _originalForceReceiverEnabled = ForceReceiver.enabled;
            ForceReceiver.enabled = false;
        }

        if (agent != null)
        {
            _originalAgentEnabled = agent.enabled;
            agent.enabled = false;
        }

        // Guardar referencia al collider principal para uso externo
        _capturedCollider = GetComponentInChildren<Collider>();
    }

    public void RestorePhysics()
    {
        if (Controller != null) Controller.enabled = _originalControllerEnabled;
        if (ForceReceiver != null) ForceReceiver.enabled = _originalForceReceiverEnabled;
        if (agent != null) agent.enabled = _originalAgentEnabled;
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