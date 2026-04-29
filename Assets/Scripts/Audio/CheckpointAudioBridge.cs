using UnityEngine;

public class CheckpointAudioBridge : MonoBehaviour
{
    public void PlayCheckpoint()
    {
        AudioManager.Instance?.PlayUICheckpoint();
    }
}