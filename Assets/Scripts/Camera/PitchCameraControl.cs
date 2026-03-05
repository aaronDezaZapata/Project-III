using System;
using UnityEngine;

public class PitchCameraControl : MonoBehaviour
{
    public bool isActive;
    
    public PlayerStateMachine playerStateMachine;

    [Tooltip("Sensibilidad base de la cámara (se multiplica por Mouse/GamepadSensitivity del Player)")]
    public float baseSensitivity = 120f;
    public float minPitch = -60f;
    public float maxPitch = 80f;

    private float pitch;

    private float EffectiveSensitivity => baseSensitivity * playerStateMachine.GetCurrentCameraSensitivity();
    
    public void SetPitch(float newPitch)
    {
        pitch = Mathf.Clamp(newPitch, minPitch, maxPitch);
        transform.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }

    private void Update()
    {
        // if (!isActive) return;
        
        Vector2 look = playerStateMachine.InputReader.LookVector * EffectiveSensitivity * Time.deltaTime;
        
        pitch -= look.y;
        pitch = Mathf.Clamp(pitch, minPitch, maxPitch);

        transform.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }
}
