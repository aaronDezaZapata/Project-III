using System;
using Unity.Cinemachine;
using UnityEngine;

public class MainCameraController : MonoBehaviour
{
    private float _defaultMouseSensitivity  = 1f;
    private float _defaultGamepadSensitivity = 1f;

    private float _currentMouseSensitivity  = 1f;
    private float _currentGamepadSensitivity = 1f;

    private bool _isUsingGamepad;

    private CinemachineInputAxisController _inputAxisController;

    private void Awake()
    {
        _inputAxisController = GetComponent<CinemachineInputAxisController>();
    }

    private void Start()
    {
        CacheDefaultGain();
    }

    private void OnEnable()
    {
        MainCanvasManager.OnGamepadSliderAction += SetGamepadSensitivity;
        MainCanvasManager.OnMouseSliderAction   += SetMouseSensitivity;
        InputHandler.OnInputDeviceChanged       += OnInputDeviceChanged;
    }

    private void OnDisable()
    {
        MainCanvasManager.OnGamepadSliderAction -= SetGamepadSensitivity;
        MainCanvasManager.OnMouseSliderAction   -= SetMouseSensitivity;
        InputHandler.OnInputDeviceChanged       -= OnInputDeviceChanged;
    }

    private void SetMouseSensitivity(float mult)
    {
        _currentMouseSensitivity = _defaultMouseSensitivity * mult;

        if (!_isUsingGamepad)
            ApplySensitivity(_currentMouseSensitivity);
    }

    private void SetGamepadSensitivity(float mult)
    {
        _currentGamepadSensitivity = _defaultGamepadSensitivity * mult;

        if (_isUsingGamepad)
            ApplySensitivity(_currentGamepadSensitivity);
    }

    private void OnInputDeviceChanged(bool isUsingGamepad)
    {
        _isUsingGamepad = isUsingGamepad;

        float targetSensitivity = _isUsingGamepad ? _currentGamepadSensitivity : _currentMouseSensitivity;
        ApplySensitivity(targetSensitivity);
    }

    private void ApplySensitivity(float sensitivity)
    {
        _inputAxisController.Controllers[1].Input.Gain = sensitivity;
    }

    private void CacheDefaultGain()
    {
        float gain = _inputAxisController.Controllers[1].Input.Gain;

        _defaultGamepadSensitivity  = gain;
        _defaultMouseSensitivity    = gain;
        _currentGamepadSensitivity  = gain;
        _currentMouseSensitivity    = gain;
    }
}
