using UnityEngine;

public class CollectibleItem : MonoBehaviour
{
    [SerializeField] private CollectibleType _type;

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        CollectibleUIManager.Instance?.CollectItem(_type);
        Destroy(gameObject);
    }
}