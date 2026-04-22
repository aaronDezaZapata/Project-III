using System;
using Unity.VisualScripting;
using UnityEngine;

public class PaintBeaconController : MonoBehaviour
{
    public bool isReusable;

    [SerializeField] private bool isUsed;

    private void OnTriggerEnter(Collider other)
    {
        if (!isReusable && isUsed) return;

        if (other.CompareTag("Player"))
        {
            GameManager.Instance.paintBeacon = null;
            isUsed = true;
            return;
        }

        if (other.GetComponent<InkProjectile>() != null)
        {
            GameManager.Instance.paintBeacon = gameObject;

            PlayerStateMachine player = GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>();
            if (player != null)
                player.PlayerAudio?.PlayTpMark();
        }
    }
}
