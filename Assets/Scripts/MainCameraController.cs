using System;
using Unity.Cinemachine;
using UnityEngine;

public class MainCameraController : MonoBehaviour
{
    private float _defaultMiceSensitivity = 1f;
    private float _defaultGamepadSensitivity = 1f;

    private float _currentMiceSense = 1f;
    private float _currentGamepadSense = 1f;
    
    private bool _isUsingGamepad;
    
    private CinemachineInputAxisController _inputAxisController;

    private void Awake()
    {
        _inputAxisController = GetComponent<CinemachineInputAxisController>();
    }

    private void Start()
    {
        GetDefaultGain();
    }

    private void OnEnable()
    {
        MainCanvasManager.OnGamepadSliderAction += SetGamepadSensitivity;
        MainCanvasManager.OnMiceSliderAction += SetMiceSensitivity;
        InputHandler.OnInputDeviceChanged += OnInputDeviceChanged;
    }

    private void OnDisable()
    {
        MainCanvasManager.OnGamepadSliderAction -= SetGamepadSensitivity;
        MainCanvasManager.OnMiceSliderAction -= SetMiceSensitivity;
        InputHandler.OnInputDeviceChanged -= OnInputDeviceChanged;
    }

    private void SetMiceSensitivity(float mult)
    {
        _currentMiceSense = _defaultMiceSensitivity * mult;
        
        if (!_isUsingGamepad)
        {
            ApplySensitivity(_currentMiceSense);
        }
    }
    
    private void SetGamepadSensitivity(float mult)
    {
        _currentGamepadSense = _defaultGamepadSensitivity * mult;
        
        if (_isUsingGamepad)
        {
            ApplySensitivity(_currentGamepadSense);
        }
    }
    
    private void OnInputDeviceChanged(bool isUsingGamepad)
    {
        _isUsingGamepad = isUsingGamepad;
        
        float targetSensitivity = _isUsingGamepad ? _currentGamepadSense : _currentMiceSense;
        ApplySensitivity(targetSensitivity);
    }
    
    private void ApplySensitivity(float sensitivity)
    {
        _inputAxisController.Controllers[1].Input.Gain = sensitivity;
    }

    private void GetDefaultGain()
    {
        float currentGain = _inputAxisController.Controllers[1].Input.Gain;
        
        _defaultGamepadSensitivity = currentGain;
        _defaultMiceSensitivity = currentGain;
        
        _currentGamepadSense = currentGain;
        _currentMiceSense = currentGain;
    }
}
