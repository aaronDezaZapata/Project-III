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
    
    protected Dictionary<Type, State> states = new Dictionary<Type, State>();

    private void Update()
    {
        currentState?.Tick(Time.deltaTime);
    }
    
    public void AddState(State state)
    {
        states.Add(state.GetType(), state);
    }
    
    public void SwitchState(Type newStateType)
    {
        if (currentState != null && currentState.GetType() == newStateType) { return; }

        currentState?.Exit();
        
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
