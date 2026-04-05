using UnityEngine;

public class UIAudioBridge : MonoBehaviour
{
    public void PlayConfirm() => AudioManager.Instance?.PlayUIMenuConfirm();
    public void PlayBack() => AudioManager.Instance?.PlayUIMenuBack();
    public void PlayPause() => AudioManager.Instance?.PlayUIPause();
    public void PlayError() => AudioManager.Instance?.PlayUIError();
}