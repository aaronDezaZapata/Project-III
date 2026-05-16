using UnityEngine;
using System.Collections.Generic;
using System.Collections;

public abstract class State
{
    public abstract void Enter();
    public abstract void Tick(float deltaTime);
    public abstract void Exit();
}

