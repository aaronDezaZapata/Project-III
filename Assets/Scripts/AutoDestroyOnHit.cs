using UnityEngine;

public class AutoDestroyOnHit : MonoBehaviour
{
    [SerializeField] private float maxLifetime = 8f;
    [SerializeField] private float destroyDelayOnHit = 0f;

    private void OnEnable()
    {
        Destroy(gameObject, maxLifetime);
    }

    private void OnCollisionEnter(Collision collision)
    {
        Destroy(gameObject, destroyDelayOnHit);
    }
}
