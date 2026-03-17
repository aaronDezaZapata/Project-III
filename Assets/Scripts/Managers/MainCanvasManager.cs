using System;
using UnityEngine;
using UnityEngine.UI;

public class MainCanvasManager : MonoBehaviour
{
    #region Variables

    // Game Pause State
    [SerializeField] private bool isOnPause;

    /// Game Panels ///
    [SerializeField] private GameObject inGamePanel;
    [SerializeField] private GameObject crosshairPanel;
    [SerializeField] private GameObject pausePanel;
    [SerializeField] private GameObject settingsPanel;
    
    /// Sliders ///
    
    // Camera
    [SerializeField] private Slider camGamepadSenseSlider;
    [SerializeField] private Slider camMouseSenseSlider;
    // Aim Camera
    [SerializeField] private Slider aimCamGamepadSenseSlider;
    [SerializeField] private Slider aimCamMouseSenseSlider;
    
    // Audio Sliders
    [SerializeField] private Slider musicAudioSlider;
    [SerializeField] private Slider sfxAudioSlider;

    
    ///  Default Camera Sense ///
    private float defaultGamepadSense;
    private float defaultMiceSense;
    
    ///  Default Aim Camera Sense ///
    private float defaultAimGamepadSense;
    private float defaultAimMiceSense;

    #endregion

    private void Start()
    {
        IdlePanelConfig();
        
        GetInitialSettings();
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
        // Set sensitivity
    }
    
    private void OnAimMiceSlider(float mult)
    {
        float sensitivity = mult * defaultAimMiceSense;
        // Set sensitivity
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
        defaultMiceSense = GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().MiceSensitivity;
        defaultGamepadSense = GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().GamepadSensitivity;
        
        /// AIM Default Settings ///
        defaultAimMiceSense = GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().MiceAimSensitivity;
        defaultAimGamepadSense = GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().GamepadAimSensitivity;
    }
}
