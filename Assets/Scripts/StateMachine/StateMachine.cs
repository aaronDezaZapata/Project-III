using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices.WindowsRuntime;
using Unity.Cinemachine;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;

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
    }

    public State GetCurrentState()
    {
        return currentState;
    }
}
