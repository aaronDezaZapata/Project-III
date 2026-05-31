using UnityEngine;
using UnityEngine.UI;

public class CheatsOptionsController : MonoBehaviour
{
    [Header("Fly Mode")]
    [SerializeField] private Image _flyModeButton;
    [SerializeField] private Color _onFlyModeColor;
    [SerializeField] private Color _offFlyModeColor;
    
    private bool _isFlyMode;
    
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
