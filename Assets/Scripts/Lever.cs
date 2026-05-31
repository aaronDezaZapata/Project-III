using UnityEngine;

public class Lever : MonoBehaviour
{
    [Header("Identifier")]
    [Tooltip("Unique ID that must match the leverID of the platform it controls.")]
    [SerializeField] private string _leverId = "lever_01";

    [Tooltip("If true, the lever can only be activated once.")]
    [SerializeField] private bool _oneShot;

    [Tooltip("If true, toggles between activate/deactivate (useful for looping platforms).")]
    [SerializeField] private bool _toggle;

    private bool _used;
    private bool _isOn;

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Player")) return;
        InputHandler.InteractionEvent += Activate;
    }

    private void OnTriggerExit(Collider other)
    {
        if (!other.CompareTag("Player")) return;
        InputHandler.InteractionEvent -= Activate;
    }

    private void Activate()
    {
        if (_oneShot && _used) return;

        if (_toggle) _isOn = !_isOn;

        _used = true;
        GameManager.Instance.OnLeverActivated?.Invoke(_leverId);
    }
}
