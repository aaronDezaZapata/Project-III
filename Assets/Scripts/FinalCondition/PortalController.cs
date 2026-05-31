using System.Collections.Generic;
using UnityEngine;

public class PortalController : MonoBehaviour
{
    [Header("Portal")]
    [SerializeField] private GameObject _portalVisual;
    [SerializeField] private Collider _portalTrigger;
    [SerializeField] private ParticleSystem _openParticles;
    [SerializeField] private Animator _animator;

    [Header("Auto Register Shards")]
    [SerializeField] private Transform _shardsParent;
    [SerializeField] private string _shardNamePrefix = "shard";

    [Header("Material Animation")]
    [SerializeField] private Renderer[] _portalRenderers;
    [SerializeField] private string _effectPropertyName = "_Effect";
    [SerializeField] private float _startEffectValue  = 30f;
    [SerializeField] private float _endEffectValue    = 1000f;
    [SerializeField] private float _revealDuration    = 2f;

    private Material[] _portalMaterialInstances;
    private bool _isRevealing;
    private float _revealTimer;

    public bool IsRevealFinished { get; private set; }

    private void Start()
    {
        if (_portalVisual != null)
            _portalVisual.SetActive(false);

        if (_portalTrigger != null)
            _portalTrigger.enabled = false;

        AutoRegisterPortalRenderers();
        CreateMaterialInstances();
        SetEffectValue(_startEffectValue);
    }

    private void Update()
    {
        if (!_isRevealing) return;

        _revealTimer += Time.deltaTime;

        float t = Mathf.Clamp01(_revealTimer / _revealDuration);
        SetEffectValue(Mathf.Lerp(_startEffectValue, _endEffectValue, t));

        if (t >= 1f)
        {
            _isRevealing = false;
            IsRevealFinished = true;

            if (_portalTrigger != null)
                _portalTrigger.enabled = true;
        }
    }

    public void OpenPortal()
    {
        if (_portalVisual != null)  _portalVisual.SetActive(true);
        if (_openParticles != null) _openParticles.Play();
        if (_animator != null)      _animator.SetTrigger("Open");
        if (_portalTrigger != null) _portalTrigger.enabled = false;

        StartRevealAnimation();
    }

    private void StartRevealAnimation()
    {
        _revealTimer     = 0f;
        _isRevealing     = true;
        IsRevealFinished = false;

        SetEffectValue(_startEffectValue);
    }

    private void AutoRegisterPortalRenderers()
    {
        if (_shardsParent == null) return;

        List<Renderer> found = new List<Renderer>();

        foreach (Transform child in _shardsParent)
        {
            if (!child.name.StartsWith(_shardNamePrefix)) continue;

            Renderer r = child.GetComponent<Renderer>();
            if (r != null) found.Add(r);
        }

        _portalRenderers = found.ToArray();
    }

    private void CreateMaterialInstances()
    {
        if (_portalRenderers == null || _portalRenderers.Length == 0) return;

        _portalMaterialInstances = new Material[_portalRenderers.Length];

        for (int i = 0; i < _portalRenderers.Length; i++)
        {
            if (_portalRenderers[i] == null) continue;
            _portalMaterialInstances[i] = _portalRenderers[i].material;
        }
    }

    private void SetEffectValue(float value)
    {
        if (_portalMaterialInstances == null) return;

        for (int i = 0; i < _portalMaterialInstances.Length; i++)
        {
            if (_portalMaterialInstances[i] == null) continue;

            if (_portalMaterialInstances[i].HasFloat(_effectPropertyName))
                _portalMaterialInstances[i].SetFloat(_effectPropertyName, value);
        }
    }

    public void HideShards()
    {
        if (_portalRenderers == null) return;

        for (int i = 0; i < _portalRenderers.Length; i++)
        {
            if (_portalRenderers[i] == null) continue;
            _portalRenderers[i].gameObject.SetActive(false);
        }
    }
}
