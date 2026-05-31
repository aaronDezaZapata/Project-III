using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class CheatsOptionsController : MonoBehaviour
{
    [Header("Fly Mode")]
    [SerializeField] private Image _flyModeButton;
    [SerializeField] private Color _onFlyModeColor;
    [SerializeField] private Color _offFlyModeColor;
    
    [Header("Checkpoints")]
    [SerializeField] private List<GameObject> _checkpointsList = new List<GameObject>();
    
    [Header("Debug")]
    [SerializeField] private bool _showDebugInfo;
    
    private bool _isFlyMode;

    private void Awake()
    {
        Debug.developerConsoleEnabled = false;
    }

    private void OnEnable()
    {
        EventSystem.current.SetSelectedGameObject(null);
        EventSystem.current.SetSelectedGameObject(_flyModeButton.gameObject);
    }

    public void TriggerPlayerFlyMode()
    {
        _isFlyMode = !_isFlyMode;

        if (_isFlyMode)
        {
            GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().SwitchState(typeof(PlayerFlyState));
            _flyModeButton.color = _onFlyModeColor;
        }
        else
        {
            GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().ReturnToMainState();
            _flyModeButton.color = _offFlyModeColor;
        }
    }

    public void GoToCheckpoint(int id)
    {
        GameManager.Instance.GetPlayer().transform.position = _checkpointsList[id].transform.position;
    }
    
    public void ResetScene()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
    }

    public void GetAllCollectables()
    {
        for (int i = 0; i < 6; i++)
        {
            GameManager.Instance.CollectStar();
        }
    }
}
