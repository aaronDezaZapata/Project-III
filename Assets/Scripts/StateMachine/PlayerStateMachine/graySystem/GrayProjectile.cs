using UnityEngine;

/// <summary>
/// Componente para objetos lanzados como proyectiles por la aspiradora gris.
/// DESTRUYE TODO DE UN GOLPE - Enemigos y objetos destructibles.
/// </summary>
public class GrayProjectile : MonoBehaviour
{
    [HideInInspector] public float damage = 999f; // Daño suficiente para matar de un golpe
    [HideInInspector] public AbsorbableObject owner;

    private bool hasHit = false;
    private float lifetime = 5f;
    private float spawnTime;

    private void Start()
    {
        spawnTime = Time.time;
    }

    private void Update()
    {
        // Destruir después de cierto tiempo si no ha golpeado nada
        if (Time.time - spawnTime > lifetime)
        {
            if (owner != null)
            {
                Destroy(owner.gameObject);
            }
            else
            {
                Destroy(gameObject);
            }
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (hasHit) return;
        hasHit = true;

        Vector3 impactPoint = collision.GetContact(0).point;
        Vector3 impactNormal = collision.GetContact(0).normal;

        // DESTRUIR OBJETO DESTRUCTIBLE (Un golpe)
        DestructibleObject destructible = collision.gameObject.GetComponent<DestructibleObject>();
        if (destructible != null)
        {
            destructible.DestroyInstantly(impactPoint);
            DestroyProjectile();
            return;
        }

        // MATAR ENEMIGO (Un golpe)
        EnemyScript enemy = collision.gameObject.GetComponent<EnemyScript>();
        if (enemy != null)
        {
            //enemy.Die(); // Matar directamente
            Debug.Log($"Proyectil mató enemigo: {enemy.name}");
            DestroyProjectile();
            return;
        }

        // IMPACTO EN SUPERFICIE NORMAL
        CreateImpactEffect(impactPoint, impactNormal);
        DestroyProjectile();
    }

    private void DestroyProjectile()
    {
        // Destruir el componente GrayProjectile
        Destroy(this);

        // Destruir el objeto owner si existe
        if (owner != null)
        {
            Destroy(owner.gameObject, 0.05f);
        }
        else
        {
            // Si no hay owner, destruir este gameObject
            Destroy(gameObject, 0.05f);
        }
    }

    private void CreateImpactEffect(Vector3 position, Vector3 normal)
    {
        // Aquí podrías instanciar partículas de impacto
        Debug.Log($"Proyectil impactó en {position}");

        // TODO: Instanciar partículas de impacto si las tienes
        // Instantiate(impactParticlesPrefab, position, Quaternion.LookRotation(normal));
    }
}