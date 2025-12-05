using UnityEngine;
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


    void Awake()
    {
        //Añadir Estados Ejemplo

        /*
        AddState(new EnemyDeadState(this));
        */

        // Lo mismo con SwitchState para empezar con el primer estado
    }

    void Start()
    {
        
    }

}
