using System;
using JetBrains.Annotations;
using UnityEngine;
using UnityEngine.UI;

public class MainCanvasManager : MonoBehaviour
{
    #region Variables

    // Game Pause State
    [SerializeField] private bool isOnPause;

    /// Game Panels ///
    [Header("Panels")]
    [SerializeField] private GameObject inGamePanel;
    [SerializeField] private GameObject crosshairPanel;
    [SerializeField] private GameObject pausePanel;
    [SerializeField] private GameObject settingsPanel;
    
    /// Sliders ///
    [Header("Sliders")]
    // Camera
    [SerializeField] private Slider _gamepadSlider;
    [SerializeField] private Slider _mouseSlider;
    [Space(5f)]
    // Aim Camera
    [SerializeField] private Slider _aimGamepadSlider;
    [SerializeField] private Slider _aimMouseSlider;
    
    [Space(10f)]
    
    // Audio Sliders
    [SerializeField] private Slider musicSlider;
    [SerializeField] private Slider sfxSlider;

    
    ///  Default Camera Sense ///
    private float defaultGamepadSense;
    private float defaultMiceSense;
    
    ///  Default Aim Camera Sense ///
    private float defaultAimGamepadSense;
    private float defaultAimMiceSense;
    
    private PlayerStateMachine _player;

    #endregion

    private void Awake()
    {
        _player = GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>();
    }

    private void Start()
    {
        IdlePanelConfig();
        GetInitialSettings();
        SliderAddListeners();
    }

    private void OnEnable()
    {
        PlayerShootingState.OnAiming += HandleShooting;
        InputHandler.OnPauseGameEvent += PauseHandler;
    }

    private void OnDisable()
    {
        PlayerShootingState.OnAiming -= HandleShooting;
        InputHandler.OnPauseGameEvent -= PauseHandler;
    }

    #region Panel States

    public void IdlePanelConfig()
    {
        isOnPause = false;
        
        Time.timeScale = 1f;
        
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
        
        crosshairPanel.SetActive(false);
        pausePanel.SetActive(false);
        settingsPanel.SetActive(false);
        inGamePanel.SetActive(true);
    }
    
    public void PauseOpen()
    {
        isOnPause = true;
        
        Time.timeScale = 0f;
        
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
        
        inGamePanel.SetActive(false);
        crosshairPanel.SetActive(false);
        settingsPanel.SetActive(false);
        pausePanel.SetActive(true);
    }
    
    private void CrosshairOpen()
    {
        inGamePanel.SetActive(false);
        pausePanel.SetActive(false);
        settingsPanel.SetActive(false);
        crosshairPanel.SetActive(true);
    }

    #endregion

    #region Slider Settings

    private void OnGamepadSlider(float mult)
    {
        float sensitivity = mult * defaultGamepadSense;
        // Set sensitivity
    }

    private void OnMiceSlider(float mult)
    {
        float sensitivity = mult * defaultMiceSense;
        // Set sensitivity
    }
    
    private void OnAimGamepadSlider(float mult)
    {
        float sensitivity = mult * defaultAimGamepadSense;
        _player.GamepadAimSensitivity = sensitivity;
    }
    
    private void OnAimMiceSlider(float mult)
    {
        float sensitivity = mult * defaultAimMiceSense;
        _player.MiceAimSensitivity = sensitivity;
    }

    #endregion
    
    private void PauseHandler()
    {
        if (isOnPause)
            IdlePanelConfig();
        else
            PauseOpen();
    }
    
    // Crosshair settings
    private void HandleShooting(bool isAiming)
    {
        if (isOnPause) return;
        
        if (isAiming) CrosshairOpen();
        else IdlePanelConfig();
    }

    private void GetInitialSettings()
    {
        /// CAMERA Default Settings ///
        defaultMiceSense = _player.MiceSensitivity;
        defaultGamepadSense = _player.GamepadSensitivity;
        
        /// AIM Default Settings ///
        defaultAimMiceSense = _player.MiceAimSensitivity;
        defaultAimGamepadSense = _player.GamepadAimSensitivity;
    }

    private void SliderAddListeners()
    {
        _gamepadSlider.onValueChanged.AddListener(OnGamepadSlider);
        _mouseSlider.onValueChanged.AddListener(OnMiceSlider);
        _aimGamepadSlider.onValueChanged.AddListener(OnAimGamepadSlider);
        _aimMouseSlider.onValueChanged.AddListener(OnAimMiceSlider);
        // TBD
        /*musicAudioSlider.onValueChanged.AddListener();
        sfxAudioSlider.onValueChanged.AddListener();*/
    }
}
