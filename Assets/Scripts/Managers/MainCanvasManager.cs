using System;
using JetBrains.Annotations;
using UnityEngine;
using UnityEngine.Audio;
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
    
    [Space(10f)]
    [Header("Toggles")]
    [SerializeField] private Toggle _XInvertToggle;
    [SerializeField] private Toggle _aimXInvertToggle;

    
    ///  Default Camera Sense ///
    private float defaultGamepadSense = 1f;
    private float defaultMiceSense = 1f;
    
    ///  Default Aim Camera Sense ///
    private float defaultAimGamepadSense;
    private float defaultAimMiceSense;
    
    [SerializeField] private AudioMixer _audioMixer;
    
    private PlayerStateMachine _player;
    
    public static Action<float> OnMiceSliderAction;
    public static Action<float> OnGamepadSliderAction;

    #endregion

    private void Awake()
    {
        _player = GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>();
    }

    private void Start()
    {
        IdlePanelConfig();
        GetInitialSettings();
        SetSettingsListeners();
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

    #region Settings Methods

    // Camera Settings //
    private void OnGamepadSlider(float mult)
    {
        float sensitivity = mult * defaultGamepadSense;
        OnGamepadSliderAction?.Invoke(sensitivity);
    }

    private void OnMiceSlider(float mult)
    {
        float sensitivity = mult * defaultMiceSense;
        OnMiceSliderAction?.Invoke(sensitivity);
    }
    
    // Aim Camera Settings //
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

    private void OnAimXInvertToggle(bool value)
    {
        _player.AimXAxisInverted = value;
    }
    
    // Audio Settings //
    public void SetMasterVolume(float level)
    {
        _audioMixer.SetFloat("masterVolume", Mathf.Log10(level) * 20f);
    }
    
    public void SetSoundFXVolume(float level)
    {
        _audioMixer.SetFloat("soundFXVolume", Mathf.Log10(level) * 20f);
    }
    
    public void SetMusicVolume(float level)
    {
        _audioMixer.SetFloat("musicVolume", Mathf.Log10(level) * 20f);
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

    private void SetSettingsListeners()
    {
        /// Sliders Listeners ///
        _gamepadSlider.onValueChanged.AddListener(OnGamepadSlider);
        _mouseSlider.onValueChanged.AddListener(OnMiceSlider);
        _aimGamepadSlider.onValueChanged.AddListener(OnAimGamepadSlider);
        _aimMouseSlider.onValueChanged.AddListener(OnAimMiceSlider);
        
        /// Toggles Listeners ///
        // _XInvertToggle.onValueChanged.AddListener(); // TBD
        _aimXInvertToggle.onValueChanged.AddListener(OnAimXInvertToggle);
        // TBD
        /*musicAudioSlider.onValueChanged.AddListener();
        sfxAudioSlider.onValueChanged.AddListener();*/
    }
}
