using UnityEngine;

public class PitchCameraControl : MonoBehaviour
{
    [SerializeField] private PlayerStateMachine _player;

    [SerializeField] private float _baseSensitivity = 120f;
    [SerializeField] private float _minPitch = -60f;
    [SerializeField] private float _maxPitch  = 80f;

    private float _pitch;

    private float EffectiveSensitivity => GetCurrentSensitivity();

    public void SetPitch(float newPitch)
    {
        _pitch = Mathf.Clamp(newPitch, _minPitch, _maxPitch);
        transform.localRotation = Quaternion.Euler(_pitch, 0f, 0f);
    }

    private void Update()
    {
        Vector2 look = _player.InputReader.LookVector * (EffectiveSensitivity * Time.deltaTime);

        _pitch -= look.y;
        _pitch  = Mathf.Clamp(_pitch, _minPitch, _maxPitch);

        transform.localRotation = Quaternion.Euler(_pitch, 0f, 0f);
    }

    private float GetCurrentSensitivity()
    {
        float sign = _player.AimXAxisInverted ? -1f : 1f;
        return sign * _baseSensitivity * _player.GetCurrentCameraSensitivity();
    }
}
