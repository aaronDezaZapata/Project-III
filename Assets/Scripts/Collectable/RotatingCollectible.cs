using UnityEngine;

public class RotatingCollectible : MonoBehaviour
{
    [Header("Rotación")]
    [SerializeField] private float rotationSpeed = 120f;
    [SerializeField] private Vector3 rotationAxis = Vector3.up;

    [Header("Recogida")]
    [SerializeField] private string playerTag = "Player";

    [Header("Opcional")]
    [SerializeField] private GameObject collectVFX;

    private void Update()
    {
        transform.Rotate(rotationAxis * rotationSpeed * Time.deltaTime, Space.Self);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag(playerTag))
            return;

        Collect();
    }

    private void Collect()
    {

        if (collectVFX != null)
        {
            Instantiate(collectVFX, transform.position, Quaternion.identity);
        }

        Destroy(gameObject);
    }
}