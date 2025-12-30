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
    }


    private void Start()
    {
        SwitchState(typeof(EnemyIdleState));
    }


    void OnParticleCollision(GameObject other)
    {
        // Verificamos que sea el chorro de agua del jugador (por si hay otras partículas)
        if (other.CompareTag("WaterJet"))
        {
            // Llamamos a la función de inflar manualmente
            // (Tendrías que hacer pública la función Inflate() o usar una variable)
            
            isGettingAttacked = true;

            _sprayResetTimer = _sprayCooldown;

            if (currentState.GetType() != typeof(EnemyInflatableState))
            {
                SwitchState(typeof(EnemyInflatableState));
                return;
            }
            

        }
    }
}
