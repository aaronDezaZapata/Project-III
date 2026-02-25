using System;
using UnityEngine;

public class PitchCameraControl : MonoBehaviour
{
    public bool isActive;
    
    public PlayerStateMachine playerStateMachine;

    [Tooltip("Sensibilidad base de la cámara (se multiplica por CameraSensitivity del Player)")]
    public float baseSensitivity = 120f;
    public float minPitch = -60f;
    public float maxPitch = 80f;

    private float pitch;

    /// <summary>
    /// Sensibilidad efectiva = baseSensitivity * CameraSensitivity del Player
    /// </summary>
    private float EffectiveSensitivity => baseSensitivity * playerStateMachine.CameraSensitivity;

    private void Update()
    {
        // if (!isActive) return;
        
        Vector2 look = playerStateMachine.InputReader.LookVector * EffectiveSensitivity * Time.deltaTime;
        
        pitch -= look.y;
        pitch = Mathf.Clamp(pitch, minPitch, maxPitch);

        transform.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }
}
