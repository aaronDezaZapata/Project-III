using System;
using System.Collections.Generic;
using UnityEngine;

public class StateMachine : MonoBehaviour
{
    protected State currentState;

    // Diccionario para guardar las instancias de los estados
    protected Dictionary<Type, State> states = new Dictionary<Type, State>();

    private void Update()
    {
        currentState?.Tick(Time.deltaTime);
    }

    // Un nuevo método para añadir los estados
    public void AddState(State state)
    {
        states.Add(state.GetType(), state);
    }

    // Cambia SwitchState para que acepte un TIPO de estado en lugar de una instancia
    public void SwitchState(Type newStateType)
    {
        if (currentState != null && currentState.GetType() == newStateType) { return; }

        currentState?.Exit();

        // Buscamos el estado en el diccionario
        if (states.TryGetValue(newStateType, out State newState))
        {
            currentState = newState;
            currentState.Enter();
        }
        else
        {
            // --- NUEVO BLOQUE DE ERROR ---
            // Si el estado no se encuentra lanzamos un error claro.
            Debug.LogError(
                $"El estado '{newStateType.FullName}' no se encontró en el diccionario de '{gameObject.name}'. " +
                $"¿Olvidaste añadirlo con AddState() en el método Awake() del Enemy o Player StateMachine?"
            );
            // -----------------------------
        }
    }

    public State GetCurrentState()
    {
        return currentState;
    }
}
