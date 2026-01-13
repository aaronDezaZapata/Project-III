using System;
using UnityEngine;

public class PitchCameraControl : MonoBehaviour
{
    public bool isActive;
    
    public PlayerStateMachine playerStateMachine;

    public float sensitivity = 120f;
    public float minPitch = -60f;
    public float maxPitch = 80f;

    private float pitch;

    private void Update()
    {
        // if (!isActive) return;
        
        Vector2 look = playerStateMachine.InputReader.LookVector * sensitivity * Time.deltaTime;
        
        pitch -= look.y;
        pitch = Mathf.Clamp(pitch, minPitch, maxPitch);

        transform.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }
}
