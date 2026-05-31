using UnityEngine;

public class FoamBobbing : MonoBehaviour
{
    [Header("Horizontal Movement")]
    [SerializeField] private float _horizontalAmplitude = 0.15f;
    [SerializeField] private float _horizontalSpeed     = 1.2f;

    [Header("Vertical Movement")]
    [SerializeField] private float _verticalAmplitude = 0.08f;
    [SerializeField] private float _verticalSpeed     = 1.8f;

    [Header("Scale")]
    [SerializeField] private float _scaleAmplitude = 0.05f;
    [SerializeField] private float _scaleSpeed     = 1.4f;

    [Header("Phase Offset")]
    [SerializeField] private float _phaseOffset;

    private Vector3 _startLocalPos;
    private Vector3 _startLocalScale;

    private void Start()
    {
        _startLocalPos   = transform.localPosition;
        _startLocalScale = transform.localScale;
    }

    private void Update()
    {
        float t = Time.time + _phaseOffset;

        float x = Mathf.Sin(t * _horizontalSpeed) * _horizontalAmplitude;
        float y = Mathf.Sin(t * _verticalSpeed) * _verticalAmplitude;
        float s = 1f + Mathf.Sin(t * _scaleSpeed) * _scaleAmplitude;

        transform.localPosition = _startLocalPos + new Vector3(x, y, 0f);
        transform.localScale    = new Vector3(
            _startLocalScale.x * s,
            _startLocalScale.y * s,
            _startLocalScale.z
        );
    }
}
