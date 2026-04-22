using UnityEngine;

public class StarCollectible : MonoBehaviour
{
    [SerializeField] private int starValue = 1;

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        if (GameManager.Instance != null)
        {
            GameManager.Instance.CollectStar(starValue);
        }

        Destroy(gameObject);
    }
}