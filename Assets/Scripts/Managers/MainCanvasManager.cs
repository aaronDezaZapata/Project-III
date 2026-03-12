using System;
using UnityEngine;

public class MainCanvasManager : MonoBehaviour
{
    #region Variables

    // Game Pause State
    [SerializeField] private bool isOnPause;

    // Game Panels
    [SerializeField] private GameObject inGamePanel;
    [SerializeField] private GameObject crosshairPanel;
    [SerializeField] private GameObject pausePanel;
    [SerializeField] private GameObject settingsPanel;

    #endregion

    private void Start()
    {
        IdlePanelConfig();
    }

    private void OnEnable()
    {
        PlayerShootingState.isAiming += HandleShooting;
        InputHandler.OnPauseGameEvent += PauseHandler;
    }

    private void OnDisable()
    {
        InputHandler.OnPauseGameEvent -= PauseHandler;
    }

    private void PauseHandler()
    {
        if (isOnPause)
            IdlePanelConfig();
        else
            PauseOpen();
        
    }
    
    // Panel control methods
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
    
    // Crosshair settings
    private void HandleShooting(bool isAiming)
    {
        if (isOnPause) return;
        
        if (isAiming) CrosshairOpen();
        else IdlePanelConfig();
    }
    
    private void CrosshairOpen()
    {
        inGamePanel.SetActive(false);
        pausePanel.SetActive(false);
        settingsPanel.SetActive(false);
        crosshairPanel.SetActive(true);
    }
}
