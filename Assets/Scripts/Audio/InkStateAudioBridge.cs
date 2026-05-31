using UnityEngine;

public class InkStateAudioBridge : MonoBehaviour
{
    public void SetBaseInk() => AudioManager.Instance?.SetInkState(InkStateType.Base);
    public void SetRedInk() => AudioManager.Instance?.SetInkState(InkStateType.Red);
    public void SetBlueInk() => AudioManager.Instance?.SetInkState(InkStateType.Blue);
    public void SetGreenInk() => AudioManager.Instance?.SetInkState(InkStateType.Green);
    public void SetBlackInk() => AudioManager.Instance?.SetInkState(InkStateType.Black);
}