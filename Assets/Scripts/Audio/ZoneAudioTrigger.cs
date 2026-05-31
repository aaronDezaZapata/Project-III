using UnityEngine;

public class ZoneAudioTrigger : MonoBehaviour
{
    [SerializeField] private ZoneType zoneToSet;

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Player")) return;
        AudioManager.Instance?.SetZone(zoneToSet);
    }
}
