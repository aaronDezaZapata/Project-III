using UnityEngine;

public class AudioBootstrap : MonoBehaviour
{
    [SerializeField] private AudioManager audioManagerPrefab;

    private void Awake()
    {
        if (AudioManager.Instance == null && audioManagerPrefab != null)
            Instantiate(audioManagerPrefab);
    }
}