using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;

[System.Serializable]
public class CollectibleUIEntry
{
    public CollectibleType type;
    public Image icon;
}

public class CollectibleUIManager : MonoBehaviour
{
    public static CollectibleUIManager Instance { get; private set; }

    [Header("Collectible Icons")]
    [SerializeField] private List<CollectibleUIEntry> _entries = new();

    [Header("Alpha Settings")]
    [Range(0f, 255f)][SerializeField] private float _uncollectedAlpha = 14f;
    [Range(0f, 255f)][SerializeField] private float _collectedAlpha = 255f;

    private void Awake()
    {
        if (Instance == null) Instance = this;
        else { Destroy(gameObject); return; }

        InitializeIcons();
    }

    private void InitializeIcons()
    {
        foreach (var entry in _entries)
            SetAlpha(entry.icon, _uncollectedAlpha / 255f);
    }

    public void CollectItem(CollectibleType type)
    {
        var entry = _entries.Find(e => e.type == type);
        if (entry != null)
            SetAlpha(entry.icon, _collectedAlpha / 255f);
    }

    private void SetAlpha(Image icon, float alpha)
    {
        if (icon == null) return;
        Color c = icon.color;
        c.a = alpha;
        icon.color = c;
    }
}