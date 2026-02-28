using System;
using UnityEngine;

public class MainCanvasManager : MonoBehaviour
{
    #region Variables

    [SerializeField] private GameObject inGamePanel;
    [SerializeField] private GameObject crosshairPanel;
    [SerializeField] private GameObject pausePanel;
    [SerializeField] private GameObject settingsPanel;

    #endregion

    private void Start()
    {
        InGameOpen();
    }

    private void InGameOpen()
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
        inGamePanel.SetActive(false);
        crosshairPanel.SetActive(false);
        pausePanel.SetActive(true);
        settingsPanel.SetActive(false);
    }
    
    private void SettingsOpen()
    {
        inGamePanel.SetActive(false);
        crosshairPanel.SetActive(false);
        pausePanel.SetActive(false);
        settingsPanel.SetActive(true);
    }
}
