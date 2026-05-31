using System;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class CheatsOptionsController : MonoBehaviour
{
    [Header("Fly Mode")]
    [SerializeField] private Image _flyModeButton;
    [SerializeField] private Color _onFlyModeColor;
    [SerializeField] private Color _offFlyModeColor;
    
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
}
