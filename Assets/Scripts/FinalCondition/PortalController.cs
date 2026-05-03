using System.Collections.Generic;
using UnityEngine;

public class PortalController : MonoBehaviour
{
    [Header("Portal")]
    [SerializeField] private GameObject portalVisual;
    [SerializeField] private Collider portalTrigger;
    [SerializeField] private ParticleSystem openParticles;
    [SerializeField] private Animator animator;

    [Header("Auto Register Shards")]
    [SerializeField] private Transform shardsParent;
    [SerializeField] private string shardNamePrefix = "shard";

    [Header("Material Animation")]
    [SerializeField] private Renderer[] portalRenderers;
    [SerializeField] private string effectPropertyName = "_Effect";
    [SerializeField] private float startEffectValue = 30f;
    [SerializeField] private float endEffectValue = 1000f;
    [SerializeField] private float revealDuration = 2f;

    private Material[] portalMaterialInstances;
    private bool isRevealing = false;
    private float revealTimer = 0f;
    public bool IsRevealFinished { get; private set; } = false;

    private void Start()
    {
        if (portalVisual != null)
            portalVisual.SetActive(false);

        if (portalTrigger != null)
            portalTrigger.enabled = false;

        AutoRegisterPortalRenderers();
        CreateMaterialInstances();

        SetEffectValue(startEffectValue);
    }

    private void Update()
    {
        if (!isRevealing) return;

        revealTimer += Time.deltaTime;

        float t = revealTimer / revealDuration;
        t = Mathf.Clamp01(t);

        float currentEffectValue = Mathf.Lerp(startEffectValue, endEffectValue, t);

        SetEffectValue(currentEffectValue);

        if (t >= 1f)
        {
            isRevealing = false;
            IsRevealFinished = true;

            if (portalTrigger != null)
                portalTrigger.enabled = true;
        }
    }

    public void OpenPortal()
    {
        if (portalVisual != null)
            portalVisual.SetActive(true);

        if (openParticles != null)
            openParticles.Play();

        if (animator != null)
            animator.SetTrigger("Open");

        if (portalTrigger != null)
            portalTrigger.enabled = false;

        StartRevealAnimation();
    }

    private void StartRevealAnimation()
    {
        revealTimer = 0f;
        isRevealing = true;
        IsRevealFinished = false;

        SetEffectValue(startEffectValue);
    }

    private void AutoRegisterPortalRenderers()
    {
        if (shardsParent == null)
        {
            return;
        }

        List<Renderer> foundRenderers = new List<Renderer>();

        foreach (Transform child in shardsParent)
        {
            if (!child.name.StartsWith(shardNamePrefix)) continue;

            Renderer childRenderer = child.GetComponent<Renderer>();

            if (childRenderer != null)
            {
                foundRenderers.Add(childRenderer);
            }
        }

        portalRenderers = foundRenderers.ToArray();

    }

    private void CreateMaterialInstances()
    {
        if (portalRenderers == null || portalRenderers.Length == 0)
        {
            return;
        }

        portalMaterialInstances = new Material[portalRenderers.Length];

        for (int i = 0; i < portalRenderers.Length; i++)
        {
            if (portalRenderers[i] == null) continue;

            portalMaterialInstances[i] = portalRenderers[i].material;
        }
    }

    private void SetEffectValue(float value)
    {
        if (portalMaterialInstances == null) return;

        for (int i = 0; i < portalMaterialInstances.Length; i++)
        {
            if (portalMaterialInstances[i] == null) continue;

            if (portalMaterialInstances[i].HasFloat(effectPropertyName))
            {
                portalMaterialInstances[i].SetFloat(effectPropertyName, value);
            }
        }
    }

    public void HideShards()
    {
        if (portalRenderers == null) return;

        for (int i = 0; i < portalRenderers.Length; i++)
        {
            if (portalRenderers[i] == null) continue;

            portalRenderers[i].gameObject.SetActive(false);
        }
    }
}