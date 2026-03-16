using System;
using UnityEngine;

public class PitchCameraControl : MonoBehaviour
{
    public PlayerStateMachine playerStateMachine;

    public float baseSensitivity = 120f;
    public bool invertCamera;
    public float minPitch = -60f;
    public float maxPitch = 80f;

    private float pitch;

    private float EffectiveSensitivity => invertCamera? -baseSensitivity: baseSensitivity * playerStateMachine.GetCurrentCameraSensitivity();
    
    public void SetPitch(float newPitch)
    {
        pitch = Mathf.Clamp(newPitch, minPitch, maxPitch);
        transform.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }

    private void Update()
    {
        Vector2 look = playerStateMachine.InputReader.LookVector * EffectiveSensitivity * Time.deltaTime;
        
        pitch -= look.y;
        pitch = Mathf.Clamp(pitch, minPitch, maxPitch);

        transform.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }
}
