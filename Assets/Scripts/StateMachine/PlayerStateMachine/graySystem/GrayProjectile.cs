using UnityEngine;

/// <summary>
/// Componente para objetos lanzados como proyectiles por la aspiradora gris.
/// DESTRUYE TODO DE UN GOLPE - Enemigos y objetos destructibles.
/// Se añade automáticamente cuando un AbsorbableObject se convierte en proyectil.
/// </summary>
public class GrayProjectile : MonoBehaviour
{
    [Header("Projectile Data")]
    [HideInInspector] public float damage = 999f; // Daño masivo por defecto
    [HideInInspector] public AbsorbableObject owner;
    
    [Header("Projectile Settings")]
    [Tooltip("Tiempo de vida antes de auto-destruirse")]
    [SerializeField] private float lifetime = 5f;
    
    [Tooltip("¿Destruir en cualquier colisión?")]
    [SerializeField] private bool destroyOnAnyImpact = true;
    
    [Tooltip("Capas que el proyectil debe ignorar (ej: Player, Ink)")]
    [SerializeField] private LayerMask ignoreLayerMask;
    
    [Header("Effects")]
    [Tooltip("Prefab de partículas de impacto (opcional)")]
    [SerializeField] private GameObject impactParticlesPrefab;
    
    [Tooltip("Prefab de partículas de destrucción de enemigo (opcional)")]
    [SerializeField] private GameObject enemyDeathParticlesPrefab;
    
    [Tooltip("Sonido de impacto (opcional)")]
    [SerializeField] private AudioClip impactSound;
    
    [Tooltip("Sonido de destrucción de enemigo (opcional)")]
    [SerializeField] private AudioClip enemyDeathSound;
    
    [Tooltip("Volumen del sonido")]
    [SerializeField] [Range(0f, 1f)] private float soundVolume = 1f;
    
    [Header("Visual Trail")]
    [Tooltip("Trail renderer para efecto visual (opcional)")]
    [SerializeField] private TrailRenderer trail;
    
    [Header("Debug")]
    [SerializeField] private bool showDebugLogs = false;
    
    private bool hasHit = false;
    private float spawnTime;
    private Rigidbody rb;

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
        
        // Configurar ignoreLayerMask por defecto si no está configurado
        if (ignoreLayerMask == 0)
        {
            // Ignorar Player, Ink, UI por defecto
            ignoreLayerMask = LayerMask.GetMask("Player", "Ink", "UI");
        }
    }

    private void Start()
    {
        spawnTime = Time.time;
        
        // Obtener trail si no está asignado
        if (trail == null)
        {
            trail = GetComponent<TrailRenderer>();
        }
        
        // Si el owner tiene configurado un daño específico, usarlo
        if (owner != null && owner.projectileDamage > 0)
        {
            damage = owner.projectileDamage;
        }
        
        if (showDebugLogs)
        {
            Debug.Log($"GrayProjectile iniciado - Daño: {damage}, Lifetime: {lifetime}");
        }
    }

    private void Update()
    {
        // Auto-destruirse después del tiempo de vida
        if (Time.time - spawnTime > lifetime)
        {
            if (showDebugLogs)
            {
                Debug.Log($"Proyectil auto-destruido por tiempo de vida ({lifetime}s)");
            }
            DestroyProjectile(false);
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        // Evitar múltiples colisiones
        if (hasHit) return;
        
        // Verificar si debemos ignorar esta capa
        if (IsLayerInMask(collision.gameObject.layer, ignoreLayerMask))
        {
            if (showDebugLogs)
            {
                Debug.Log($"Proyectil ignoró colisión con: {collision.gameObject.name} (capa ignorada)");
            }
            return;
        }
        
        hasHit = true;

        Vector3 impactPoint = collision.contacts.Length > 0 ? collision.contacts[0].point : transform.position;
        Vector3 impactNormal = collision.contacts.Length > 0 ? collision.contacts[0].normal : -transform.forward;

        if (showDebugLogs)
        {
            Debug.Log($"Proyectil colisionó con: {collision.gameObject.name}");
        }

        // PRIORIDAD 1: Destruir objetos destructibles
        DestructibleObject destructible = collision.gameObject.GetComponent<DestructibleObject>();
        if (destructible != null)
        {
            HandleDestructibleImpact(destructible, impactPoint);
            return;
        }

        // PRIORIDAD 2: Destruir/dañar enemigos
        EnemyScript enemy = collision.gameObject.GetComponent<EnemyScript>();
        if (enemy != null)
        {
            HandleEnemyImpact(enemy, impactPoint);
            return;
        }

        // IMPACTO GENÉRICO (paredes, suelo, etc)
        if (destroyOnAnyImpact)
        {
            HandleGenericImpact(impactPoint, impactNormal);
        }
    }

    private void HandleDestructibleImpact(DestructibleObject destructible, Vector3 impactPoint)
    {
        if (showDebugLogs)
        {
            Debug.Log($"Proyectil DESTRUYÓ objeto: {destructible.gameObject.name}");
        }
        
        // Destruir el objeto de un golpe
        destructible.DestroyInstantly(impactPoint);
        
        // Efectos de impacto
        CreateImpactEffect(impactPoint, Vector3.up);
        PlayImpactSound(impactPoint);
        
        // Destruir el proyectil
        DestroyProjectile(true);
    }

    private void HandleEnemyImpact(EnemyScript enemy, Vector3 impactPoint)
    {
        if (showDebugLogs)
        {
            Debug.Log($"Proyectil impactó enemigo: {enemy.gameObject.name} - Daño: {damage}");
        }
        
        // Aplicar daño masivo (debería matar de un golpe)
        // enemy.TakeDamage(damage);
        enemy.GetComponent<EnemyStateMachine>();
        
        // Si el enemigo tiene método Die() directo, usarlo
        // Descomenta si tu EnemyScript tiene un método Die() público
        // enemy.Die();
        
        // Efectos especiales para enemigos
        CreateEnemyDeathEffect(impactPoint);
        PlayEnemyDeathSound(impactPoint);
        
        // Destruir el proyectil
        DestroyProjectile(true);
    }

    private void HandleGenericImpact(Vector3 impactPoint, Vector3 impactNormal)
    {
        if (showDebugLogs)
        {
            Debug.Log($"Proyectil impactó superficie en {impactPoint}");
        }
        
        // Efectos de impacto
        CreateImpactEffect(impactPoint, impactNormal);
        PlayImpactSound(impactPoint);
        
        // Destruir el proyectil
        DestroyProjectile(true);
    }

    private void CreateImpactEffect(Vector3 position, Vector3 normal)
    {
        if (impactParticlesPrefab != null)
        {
            GameObject particles = Instantiate(impactParticlesPrefab, position, Quaternion.LookRotation(normal));
            Destroy(particles, 3f); // Auto-destruir partículas después de 3 segundos
        }
    }

    private void CreateEnemyDeathEffect(Vector3 position)
    {
        GameObject particlesToUse = enemyDeathParticlesPrefab != null ? enemyDeathParticlesPrefab : impactParticlesPrefab;
        
        if (particlesToUse != null)
        {
            GameObject particles = Instantiate(particlesToUse, position, Quaternion.identity);
            Destroy(particles, 3f);
        }
    }

    private void PlayImpactSound(Vector3 position)
    {
        if (impactSound != null)
        {
            AudioSource.PlayClipAtPoint(impactSound, position, soundVolume);
        }
    }

    private void PlayEnemyDeathSound(Vector3 position)
    {
        AudioClip soundToPlay = enemyDeathSound != null ? enemyDeathSound : impactSound;
        
        if (soundToPlay != null)
        {
            AudioSource.PlayClipAtPoint(soundToPlay, position, soundVolume);
        }
    }

    private void DestroyProjectile(bool showEffect)
    {
        // Desactivar el trail renderer antes de destruir
        if (trail != null)
        {
            trail.enabled = false;
            trail.Clear();
        }
        
        // Desactivar física
        if (rb != null)
        {
            rb.isKinematic = true;
            rb.linearVelocity = Vector3.zero;
        }
        
        // Destruir el objeto owner si existe
        if (owner != null)
        {
            Destroy(owner.gameObject, 0.1f);
        }
        
        // Destruir este componente y el gameObject
        Destroy(this);
        Destroy(gameObject, 0.1f);
    }

    private bool IsLayerInMask(int layer, LayerMask mask)
    {
        return mask == (mask | (1 << layer));
    }

    // Método público para configurar el proyectil desde código
    public void Setup(float customDamage, float customLifetime = 5f)
    {
        damage = customDamage;
        lifetime = customLifetime;
        
        if (showDebugLogs)
        {
            Debug.Log($"GrayProjectile configurado - Daño: {damage}, Lifetime: {lifetime}");
        }
    }

    // Método para asignar efectos desde código si no están en el prefab
    public void SetEffects(GameObject impactParticles, GameObject enemyParticles, AudioClip impact, AudioClip enemyDeath)
    {
        if (impactParticles != null) impactParticlesPrefab = impactParticles;
        if (enemyParticles != null) enemyDeathParticlesPrefab = enemyParticles;
        if (impact != null) impactSound = impact;
        if (enemyDeath != null) enemyDeathSound = enemyDeath;
    }

    private void OnDrawGizmosSelected()
    {
        // Visualizar la velocidad del proyectil en el editor
        if (rb != null && rb.linearVelocity.magnitude > 0.1f)
        {
            Gizmos.color = Color.red;
            Gizmos.DrawLine(transform.position, transform.position + rb.linearVelocity.normalized * 2f);
        }
    }
}
