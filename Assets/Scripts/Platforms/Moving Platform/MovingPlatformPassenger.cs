using UnityEngine;

public class MovingPlatformPassenger : MonoBehaviour
{
    [SerializeField] private Transform _platformRoot;

    private Transform _originalParent;
    private Vector3 _originalScale;

    private void Awake()
    {
        if (_platformRoot == null)
            _platformRoot = transform.root;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        _originalParent = other.transform.parent;
        _originalScale  = other.transform.localScale;

        other.transform.SetParent(_platformRoot, true);
        other.transform.localScale = _originalScale;
    }

    private void OnTriggerExit(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        other.transform.SetParent(_originalParent, true);
        other.transform.localScale = _originalScale;
    }
}
