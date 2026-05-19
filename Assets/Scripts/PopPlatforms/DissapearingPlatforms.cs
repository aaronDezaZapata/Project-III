using UnityEngine;
using System.Collections;

public class DissapearingPlatforms : MonoBehaviour
{
    [Header("Timers")]
    [SerializeField] private float _disappearDelay = 2f;
    [SerializeField] private float _reappearDelay  = 3f;

    [Header("Shake Settings")]
    [SerializeField] private float _shakeDuration  = 0.6f;
    [SerializeField] private float _shakeMagnitude = 0.05f;
    [Tooltip("If empty, it will shake this object. Better to assign a child visual object to not affect physics.")]
    [SerializeField] private Transform _visualTransform;

    private Collider _collider;
    private MeshRenderer _meshRenderer;

    private bool _isPlayerOnPlatform;
    private bool _isDisappearing;
    private Vector3 _originalPosition;

    private void Start()
    {
        _collider      = GetComponent<Collider>();
        _meshRenderer  = GetComponentInChildren<MeshRenderer>();

        if (_visualTransform == null)
            _visualTransform = transform;

        _originalPosition = _visualTransform.localPosition;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player") && !_isPlayerOnPlatform && !_isDisappearing)
        {
            _isPlayerOnPlatform = true;
            StartCoroutine(DisappearCoroutine());
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player") && !_isPlayerOnPlatform && !_isDisappearing)
        {
            _isPlayerOnPlatform = true;
            StartCoroutine(DisappearCoroutine());
        }
    }

    private IEnumerator DisappearCoroutine()
    {
        _isDisappearing = true;

        float timer = _disappearDelay;

        while (timer > 0)
        {
            timer -= Time.deltaTime;

            if (timer <= _shakeDuration)
            {
                Vector3 randomPoint = _originalPosition + Random.insideUnitSphere * _shakeMagnitude;
                _visualTransform.localPosition = randomPoint;
            }

            yield return null;
        }

        _visualTransform.localPosition = _originalPosition;

        SetPlatformActive(false);

        yield return new WaitForSeconds(_reappearDelay);

        SetPlatformActive(true);
        _isPlayerOnPlatform = false;
        _isDisappearing     = false;
    }

    private void SetPlatformActive(bool active)
    {
        if (_collider != null)     _collider.enabled     = active;
        if (_meshRenderer != null) _meshRenderer.enabled = active;
    }
}
