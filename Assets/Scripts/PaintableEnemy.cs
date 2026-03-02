using System;
using UnityEngine;

public class PaintableEnemy : MonoBehaviour
{
    [Header("Pain Settings")]
    [SerializeField] private float paintDuration = 5f;
    [SerializeField] private Material paintMaterial;

    [SerializeField] private bool isPainted = false;
    private float paintTimer = 0f;
    private Material originalMaterial;
    private Renderer enemyRenderer;
    
    public bool IsPainted => isPainted && paintTimer > 0f;

    private void Awake()
    {
        enemyRenderer = GetComponentInChildren<Renderer>();
        if (enemyRenderer != null)
        {
            originalMaterial = enemyRenderer.material;
        }
    }

    private void Update()
    {
        if (isPainted)
        {
            paintTimer -= Time.deltaTime;
            if (paintTimer <= 0f)
            {
                RemovePaint();
            }
        }
    }

    public void ApplyPaint()
    {
        Debug.Log("Enemy painted!");
        isPainted = true;
        paintTimer = paintDuration;
        
        // GameManager.Instance.AddPaintedEnemy(this);

        if (paintMaterial != null && enemyRenderer != null)
        {
            enemyRenderer.material = paintMaterial;
        }
    }

    private void RemovePaint()
    {
        isPainted = false;
        // GameManager.Instance.RemovePaintedEnemy(this);
        
        if (originalMaterial != null && enemyRenderer != null)
        {
            enemyRenderer.material = originalMaterial;
        }
    }

    public void ForceClearPaint()
    {
        paintTimer = 0f;
        RemovePaint();
    }

    private void OnDisable()
    {
        if (originalMaterial != null && enemyRenderer != null)
        {
            enemyRenderer.material = originalMaterial;
        }
    }
}
