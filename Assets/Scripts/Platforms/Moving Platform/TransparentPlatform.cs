using UnityEngine;

public class TransparentPlatform : MonoBehaviour
{
    [Header("Shooting Configuration")]
    [SerializeField] private int _hitsRequired;
    [SerializeField] private string _bulletTag = "Obstacle";

    [Header("Transparency")]
    [SerializeField, Range(0f, 1f)] private float _transparentAlpha = 0.2f;
    [SerializeField, Range(0f, 1f)] private float _opaqueAlpha = 1f;

    [Header("Materials")]
    [SerializeField] private Material _transparentMaterial;
    [SerializeField] private Material _opaqueMaterial;

    private BoxCollider _solidCollider;
    private Renderer _renderer;
    private int _hitCount;
    private bool _isPainted;

    private void Start()
    {
        _solidCollider = GetComponent<BoxCollider>();
        _renderer      = GetComponent<Renderer>();

        _solidCollider.enabled = false;
        _renderer.material     = _transparentMaterial;

        SetAlpha(_transparentAlpha);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(_bulletTag))
            OnInked();
    }

    public void OnInked()
    {
        if (_isPainted) return;

        _hitCount++;

        if (_hitCount < _hitsRequired) return;

        _isPainted             = true;
        _solidCollider.enabled = true;
        _renderer.material     = _opaqueMaterial;

        SetAlpha(_opaqueAlpha);
    }

    private void SetAlpha(float alpha)
    {
        Color c = _renderer.material.color;
        c.a = alpha;
        _renderer.material.color = c;
    }
}
