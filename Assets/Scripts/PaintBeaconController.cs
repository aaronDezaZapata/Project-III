using UnityEngine;

public class PaintBeaconController : MonoBehaviour
{
    [SerializeField] private bool _isReusable;
    [SerializeField] private bool _isUsed;

    private void OnTriggerEnter(Collider other)
    {
        if (!_isReusable && _isUsed) return;

        if (other.CompareTag("Player"))
        {
            GameManager.Instance.PaintBeacon = null;
            _isUsed = true;
            return;
        }

        if (other.GetComponent<InkProjectile>() != null)
        {
            GameManager.Instance.PaintBeacon = gameObject;

            PlayerStateMachine player = GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>();
            if (player != null)
                player.PlayerAudio?.PlayTpMark();
        }
    }
}
