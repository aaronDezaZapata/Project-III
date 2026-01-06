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
        if(collision.transform.CompareTag("Enemy"))
        {
            if(collision.transform.TryGetComponent<CharacterController>(out var cc))
            {
                if(cc.velocity.magnitude > 5f)
                {
                    //Death
                    collision.transform.GetComponent<EnemyStateMachine>().GoToDeath();
                    GoToDeath();
                    return;
                    
                }
            }
        }

        if (collision.transform.CompareTag("Obstacle"))
        {
            if (Controller.velocity.magnitude > 5f)
            {
                //Death
                GoToDeath();
                return;
            }
        }

        if (collision.transform.CompareTag("Object"))
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
}
