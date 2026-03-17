using System;
using Unity.Cinemachine;
using UnityEngine;

public class MainCameraController : MonoBehaviour
{
    private float _defaultMiceSensitivity = 1f;
    private float _defaultGamepadSensitivity = 1f;

    private float _currentMiceSense = 1f;
    private float _currentGamepadSense = 1f;
    
    private bool _isUsingGamepad = GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().InputReader.IsUsingGamepad;
    
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
    }

    private void OnDisable()
    {
        MainCanvasManager.OnGamepadSliderAction -= SetGamepadSensitivity;
        MainCanvasManager.OnMiceSliderAction -= SetMiceSensitivity;
    }

    private void SetMiceSensitivity(float mult)
    {
        _currentMiceSense = _defaultMiceSensitivity * mult;
        _inputAxisController.Controllers[1].Input.Gain = _currentMiceSense;
    }
    
    private void SetGamepadSensitivity(float mult)
    {
        _currentGamepadSense = _defaultGamepadSensitivity * mult;
        _inputAxisController.Controllers[1].Input.Gain = _currentGamepadSense;
    }

    // TODO: Check
    // Puede que no sea necesario a futuro
    private void GetDefaultGain()
    {
        float currentGain = _inputAxisController.Controllers[1].Input.Gain;
        
        _defaultGamepadSensitivity = currentGain;
        _defaultMiceSensitivity = currentGain;
        
        _currentGamepadSense = currentGain;
        _currentMiceSense = currentGain;
    }
}
