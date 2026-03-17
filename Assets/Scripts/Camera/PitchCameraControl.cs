using System;
using UnityEngine;

public class PitchCameraControl : MonoBehaviour
{
    public PlayerStateMachine player;

    public float baseSensitivity = 120f;
    public float minPitch = -60f;
    public float maxPitch = 80f;

    private float pitch;

    private float EffectiveSensitivity => GetPlayerCurrentSensitivity();
    
    public void SetPitch(float newPitch)
    {
        pitch = Mathf.Clamp(newPitch, minPitch, maxPitch);
        transform.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }

    private void Update()
    {
        Vector2 look = player.InputReader.LookVector * (EffectiveSensitivity * Time.deltaTime);
        
        pitch -= look.y;
        
        pitch = Mathf.Clamp(pitch, minPitch, maxPitch);

        transform.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }

    private float GetPlayerCurrentSensitivity()
    {
        float sensitivity;
        
        if (player.AimXAxisInverted)
            sensitivity = -baseSensitivity * player.GetCurrentCameraSensitivity();
        else
            sensitivity = baseSensitivity * player.GetCurrentCameraSensitivity();

        return sensitivity;
    }
}
