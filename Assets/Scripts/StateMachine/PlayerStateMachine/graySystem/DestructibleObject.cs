using UnityEngine;

/// <summary>
/// Marca objetos como destructibles.
/// SE DESTRUYEN DE UN GOLPE por proyectiles de la aspiradora gris.
/// Sin sistema de vida, sin fragmentos (todo por partículas).
/// </summary>
public class DestructibleObject : MonoBehaviour
{
    [Header("Drop Settings")]
    [Tooltip("¿Dropea objetos al romperse?")]
    public bool dropsItems = false;

    [Tooltip("Objetos que puede dropear")]
    public GameObject[] itemsToDrop;

    [Tooltip("Cantidad de items a dropear")]
    [Range(1, 10)]
    public int dropCount = 1;

    [Header("Visual")]
    [Tooltip("Prefab de partículas al romperse")]
    public GameObject breakParticles;

    [Header("Audio (opcional)")]
    [Tooltip("Sonido al romperse")]
    public AudioClip breakSound;

    private bool isDestroyed = false;

    /// <summary>
    /// Destruye el objeto instantáneamente (un golpe)
    /// </summary>
    public void DestroyInstantly(Vector3 breakPoint)
    {
        if (isDestroyed) return;
        isDestroyed = true;

        Debug.Log($"{gameObject.name} destruido en {breakPoint}");

        // Spawn de partículas
        if (breakParticles != null)
        {
            GameObject particles = Instantiate(breakParticles, breakPoint, Quaternion.identity);
            // Las partículas se auto-destruirán después de su lifetime
            Destroy(particles, 5f);
        }

        // Reproducir sonido
        if (breakSound != null)
        {
            AudioSource.PlayClipAtPoint(breakSound, breakPoint);
        }

        // Drop de items
        if (dropsItems && itemsToDrop != null && itemsToDrop.Length > 0)
        {
            DropItems(breakPoint);
        }

        // Destruir el objeto
        Destroy(gameObject);
    }

    /// <summary>
    /// Compatibilidad con código antiguo que llame a TakeDamage
    /// </summary>
    public void TakeDamage(float damage, Vector3 hitPoint)
    {
        DestroyInstantly(hitPoint);
    }

    /// <summary>
    /// Compatibilidad con código antiguo que llame a Break
    /// </summary>
    public void Break(Vector3 breakPoint)
    {
        DestroyInstantly(breakPoint);
    }

    private void DropItems(Vector3 center)
    {
        for (int i = 0; i < dropCount; i++)
        {
            // Seleccionar item aleatorio
            GameObject itemPrefab = itemsToDrop[Random.Range(0, itemsToDrop.Length)];
            if (itemPrefab == null) continue;

            // Posición aleatoria cercana
            Vector3 randomOffset = Random.insideUnitSphere * 1f;
            randomOffset.y = Mathf.Abs(randomOffset.y); // Hacia arriba

            GameObject item = Instantiate(itemPrefab, center + randomOffset, Quaternion.identity);

            // Añadir impulso hacia arriba
            Rigidbody rb = item.GetComponent<Rigidbody>();
            if (rb != null)
            {
                rb.AddForce(Vector3.up * 3f, ForceMode.Impulse);
            }
        }
    }

    private void OnDrawGizmosSelected()
    {
        // Visualizar como destructible
        Gizmos.color = Color.red;
        Gizmos.DrawWireCube(transform.position, Vector3.one * 0.5f);

        // Dibujar icono de explosión
        Gizmos.color = new Color(1f, 0.5f, 0f, 0.3f);
        Gizmos.DrawSphere(transform.position, 0.7f);
    }
}