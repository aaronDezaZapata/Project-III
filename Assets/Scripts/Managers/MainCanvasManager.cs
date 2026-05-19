using System;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class MainCanvasManager : MonoBehaviour
{
    private bool _isOnPause;

    [Header("Panels")]
    [SerializeField] private GameObject _inGamePanel;
    [SerializeField] private GameObject _crosshairPanel;
    [SerializeField] private GameObject _pausePanel;
    [SerializeField] private GameObject _settingsPanel;

    [Header("Sliders")]
    [SerializeField] private Slider _gamepadSlider;
    [SerializeField] private Slider _mouseSlider;
    [Space(5f)]
    [SerializeField] private Slider _aimGamepadSlider;
    [SerializeField] private Slider _aimMouseSlider;
    [Space(10f)]
    [SerializeField] private Slider _musicSlider;
    [SerializeField] private Slider _sfxSlider;

    [Space(10f)]
    [Header("Toggles")]
    [SerializeField] private Toggle _xInvertToggle;
    [SerializeField] private Toggle _aimXInvertToggle;

    private float _defaultGamepadSensitivity = 1f;
    private float _defaultMouseSensitivity   = 1f;
    private float _defaultAimGamepadSensitivity;
    private float _defaultAimMouseSensitivity;

    [SerializeField] private AudioMixer _audioMixer;

    private PlayerStateMachine _player;

    public static Action<float> OnMouseSliderAction;
    public static Action<float> OnGamepadSliderAction;

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
        _isOnPause = false;

        Time.timeScale = 1f;
        AudioManager.Instance?.SetPaused(false);

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        _crosshairPanel.SetActive(false);
        _pausePanel.SetActive(false);
        _settingsPanel.SetActive(false);
        _inGamePanel.SetActive(true);
    }

    public void PauseOpen()
    {
        _isOnPause = true;

        Time.timeScale = 0f;
        AudioManager.Instance?.SetPaused(true);

        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;

        _inGamePanel.SetActive(false);
        _crosshairPanel.SetActive(false);
        _settingsPanel.SetActive(false);
        _pausePanel.SetActive(true);
    }

    private void CrosshairOpen()
    {
        _inGamePanel.SetActive(false);
        _pausePanel.SetActive(false);
        _settingsPanel.SetActive(false);
        _crosshairPanel.SetActive(true);
    }

    #endregion

    #region Settings Methods

    private void OnGamepadSlider(float mult)
    {
        float sensitivity = mult * _defaultGamepadSensitivity;
        OnGamepadSliderAction?.Invoke(sensitivity);
    }

    private void OnMouseSlider(float mult)
    {
        float sensitivity = mult * _defaultMouseSensitivity;
        OnMouseSliderAction?.Invoke(sensitivity);
    }

    private void OnAimGamepadSlider(float mult)
    {
        _player.GamepadAimSensitivity = mult * _defaultAimGamepadSensitivity;
    }

    private void OnAimMouseSlider(float mult)
    {
        _player.MiceAimSensitivity = mult * _defaultAimMouseSensitivity;
    }

    private void OnAimXInvertToggle(bool value)
    {
        _player.AimXAxisInverted = value;
    }

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
        if (_isOnPause)
            IdlePanelConfig();
        else
            PauseOpen();
    }

    private void HandleShooting(bool isAiming)
    {
        if (_isOnPause) return;

        if (isAiming) CrosshairOpen();
        else IdlePanelConfig();
    }

    private void GetInitialSettings()
    {
        _defaultMouseSensitivity       = _player.MiceSensitivity;
        _defaultGamepadSensitivity     = _player.GamepadSensitivity;
        _defaultAimMouseSensitivity    = _player.MiceAimSensitivity;
        _defaultAimGamepadSensitivity  = _player.GamepadAimSensitivity;
    }

    private void SetSettingsListeners()
    {
        _gamepadSlider.onValueChanged.AddListener(OnGamepadSlider);
        _mouseSlider.onValueChanged.AddListener(OnMouseSlider);
        _aimGamepadSlider.onValueChanged.AddListener(OnAimGamepadSlider);
        _aimMouseSlider.onValueChanged.AddListener(OnAimMouseSlider);
        _aimXInvertToggle.onValueChanged.AddListener(OnAimXInvertToggle);
    }

    public void ExitToMainMenu()
    {
        SceneManager.LoadScene("1 - MainMenu");
    }
}
