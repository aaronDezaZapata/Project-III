using UnityEngine;

/// <summary>
/// Marca un objeto como absorbible por la mecánica gris (aspiradora).
/// Los objetos pueden ser pequeños (se absorben completamente) o grandes (se levantan).
/// </summary>
public class AbsorbableObject : MonoBehaviour
{
    [Header("Absorbable Settings")]
    [Tooltip("Tamaño del objeto (determina si se absorbe o se levanta)")]
    public AbsorbableSize size = AbsorbableSize.Small;
    
    [Tooltip("Peso del objeto (afecta velocidad de absorción)")]
    [Range(0.1f, 10f)]
    public float weight = 1f;
    
    [Tooltip("¿Puede ser usado como proyectil?")]
    public bool canBeProjectile = true;
    
    [Tooltip("Daño que hace como proyectil")]
    public float projectileDamage = 10f;
    
    [Tooltip("Velocidad del proyectil cuando se lanza")]
    public float projectileSpeed = 20f;
    
    [Header("Visual")]
    [Tooltip("Partículas al ser absorbido (opcional)")]
    public GameObject absorbParticles;
    
    [Header("State")]
    [HideInInspector] public bool isBeingAbsorbed = false;
    [HideInInspector] public bool isAbsorbed = false;
    [HideInInspector] public bool isBeingHeld = false;
    
    private Rigidbody rb;
    private Collider col;
    private Vector3 originalScale;
    private bool wasKinematic;
    private bool wasGravity;
    
    public enum AbsorbableSize
    {
        Small,   // Se absorbe completamente y desaparece
        Medium,  // Se absorbe pero es visible levitando
        Large    // Solo se puede levantar y mover
    }
    
    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
        col = GetComponent<Collider>();
        originalScale = transform.localScale;
        
        if (rb != null)
        {
            wasKinematic = rb.isKinematic;
            wasGravity = rb.useGravity;
        }
    }
    
    /// <summary>
    /// Llamado cuando empieza a ser absorbido
    /// </summary>
    public void StartAbsorption()
    {
        isBeingAbsorbed = true;
        
        if (rb != null)
        {
            rb.isKinematic = true;
            rb.useGravity = false;
        }
        
        if (col != null)
        {
            col.enabled = false;
        }
        
        // Spawn de partículas si las hay
        if (absorbParticles != null)
        {
            Instantiate(absorbParticles, transform.position, Quaternion.identity);
        }
    }
    
    /// <summary>
    /// Llamado cuando se completa la absorción
    /// </summary>
    public void CompleteAbsorption()
    {
        isBeingAbsorbed = false;
        isAbsorbed = true;
        
        // Si es pequeño, ocultarlo
        if (size == AbsorbableSize.Small)
        {
            gameObject.SetActive(false);
        }
    }
    
    /// <summary>
    /// Llamado cuando se levanta (objetos grandes)
    /// </summary>
    public void StartHolding()
    {
        isBeingHeld = true;
        
        if (rb != null)
        {
            rb.isKinematic = true;
            rb.useGravity = false;
        }
    }
    
    /// <summary>
    /// Llamado cuando se suelta
    /// </summary>
    public void Release()
    {
        isBeingAbsorbed = false;
        isAbsorbed = false;
        isBeingHeld = false;
        
        if (rb != null)
        {
            rb.isKinematic = wasKinematic;
            rb.useGravity = wasGravity;
        }
        
        if (col != null)
        {
            col.enabled = true;
        }
        
        if (size == AbsorbableSize.Small)
        {
            gameObject.SetActive(true);
        }
        
        transform.localScale = originalScale;
    }
    
    /// <summary>
    /// Convierte este objeto en un proyectil
    /// </summary>
    public void ConvertToProjectile(Vector3 direction, float speedMultiplier = 1f)
    {
        if (!canBeProjectile) return;
        
        Release();
        
        if (rb != null)
        {
            rb.isKinematic = false;
            rb.useGravity = true;
            rb.linearVelocity = direction * projectileSpeed * speedMultiplier;
        }
        
        // Añadir componente de proyectil
        GrayProjectile projectile = gameObject.AddComponent<GrayProjectile>();
        projectile.damage = projectileDamage;
        projectile.owner = this;
    }
    
    private void OnDrawGizmosSelected()
    {
        // Visualizar el tamaño
        Color gizmoColor = Color.green;
        
        switch (size)
        {
            case AbsorbableSize.Small:
                gizmoColor = Color.green;
                break;
            case AbsorbableSize.Medium:
                gizmoColor = Color.yellow;
                break;
            case AbsorbableSize.Large:
                gizmoColor = Color.red;
                break;
        }
        
        Gizmos.color = gizmoColor;
        Gizmos.DrawWireSphere(transform.position, 0.5f);
    }
}
