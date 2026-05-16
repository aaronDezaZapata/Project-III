using UnityEngine;

public class StarCollectible : MonoBehaviour
{
    [SerializeField] private int _starValue = 1;

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        GameManager.Instance?.CollectStar(_starValue);
        Destroy(gameObject);
    }
}
