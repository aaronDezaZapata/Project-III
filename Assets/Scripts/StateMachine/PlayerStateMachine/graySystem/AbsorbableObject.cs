using UnityEngine;

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
        Small,
        Large
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
        
        if (absorbParticles != null)
        {
            Instantiate(absorbParticles, transform.position, Quaternion.identity);
        }
    }
    
    public void CompleteAbsorption()
    {
        isBeingAbsorbed = false;
        isAbsorbed = true;
        
        if (size == AbsorbableSize.Small)
        {
            gameObject.SetActive(false);
        }
    }
    
    public void StartHolding()
    {
        isBeingHeld = true;
        
        if (rb != null)
        {
            rb.isKinematic = true;
            rb.useGravity = false;
        }
    }
    
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
    /// Dispara este objeto como proyectil usando su sistema de movimiento
    /// </summary>
    public void ShootAsProjectile(Vector3 direction, float speedMultiplier = 1f)
    {
        if (!canBeProjectile) return;
        
        // Activar y restaurar el objeto
        gameObject.SetActive(true);
        transform.localScale = originalScale;
        
        isBeingAbsorbed = false;
        isAbsorbed = false;
        isBeingHeld = false;
        
        EnemyStateMachine enemyStateMachine = GetComponent<EnemyStateMachine>();
        if (enemyStateMachine != null)
        {
            enemyStateMachine.isBeingThrown = true;
            // 1. Asegurar que CharacterController está activo
            CharacterController charController = GetComponent<CharacterController>();
            if (charController != null)
            {
                charController.enabled = true;
            }
            
            // 2. Desactivar NavMeshAgent (no lo necesitamos para proyectiles)
            UnityEngine.AI.NavMeshAgent navAgent = GetComponent<UnityEngine.AI.NavMeshAgent>();
            if (navAgent != null)
            {
                navAgent.enabled = false;
            }
            
            // 3. Activar ForceReceiver (CRÍTICO para el movimiento)
            ForceReceiver forceReceiver = GetComponent<ForceReceiver>();
            if (forceReceiver != null)
            {
                forceReceiver.enabled = true;
                
                // Resetear fuerzas anteriores
                forceReceiver.Reset();
                
                // Aplicar impulso usando ForceReceiver
                Vector3 force = direction * projectileSpeed * speedMultiplier;
                forceReceiver.AddForce(force);
            }
            
            // 4. Marcar enemigo como lanzado para que las colisiones lo destruyan
            float velocity = projectileSpeed * speedMultiplier;
            enemyStateMachine.MarkAsThrown(velocity);
        }
        else
        {
            if (rb != null)
            {
                rb.isKinematic = false;
                rb.useGravity = true;
                rb.constraints = RigidbodyConstraints.None;
                
                // Limpiar velocidad antes de aplicar la nueva
                rb.linearVelocity = Vector3.zero;
                rb.angularVelocity = Vector3.zero;
                
                // Aplicar velocidad en la dirección del disparo
                rb.linearVelocity = direction * projectileSpeed * speedMultiplier;
                
                // Añadir rotación para efecto visual
                rb.angularVelocity = Random.insideUnitSphere * 3f;
            }
        }
        
        // Activar colisión
        if (col != null)
        {
            col.enabled = true;
        }
    }
    
    private void OnDrawGizmosSelected()
    {
        Color gizmoColor = Color.green;
        
        switch (size)
        {
            case AbsorbableSize.Small:
                gizmoColor = Color.green;
                break;
            case AbsorbableSize.Large:
                gizmoColor = Color.red;
                break;
        }
        
        Gizmos.color = gizmoColor;
        Gizmos.DrawWireSphere(transform.position, 0.5f);
    }
}
