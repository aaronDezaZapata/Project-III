using System;
using UnityEngine;

public class MainCanvasManager : MonoBehaviour
{
    #region Variables

    [SerializeField] private bool isOnPause;

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
        InputHandler.OnAiming += HandleShooting;
    }

    private void OnDisable()
    {
        InputHandler.OnAiming -= HandleShooting;
    }

    private void HandleShooting(bool isAiming)
    {
        if (isOnPause) return;
        
        if (isAiming) CrosshairOpen();
        else IdlePanelConfig();
    }

    private void IdlePanelConfig()
    {
        inGamePanel.SetActive(true);
        crosshairPanel.SetActive(false);
        pausePanel.SetActive(false);
        settingsPanel.SetActive(false);
    }

    private void CrosshairOpen()
    {
        inGamePanel.SetActive(false);
        crosshairPanel.SetActive(true);
        pausePanel.SetActive(false);
        settingsPanel.SetActive(false);
    }
    
    private void PauseOpen()
    {
        isOnPause = true;
        inGamePanel.SetActive(false);
        crosshairPanel.SetActive(false);
        pausePanel.SetActive(true);
        settingsPanel.SetActive(false);
    }
}
