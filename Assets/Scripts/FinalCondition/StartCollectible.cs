using UnityEngine;

public class StarCollectible : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        GameManager.Instance?.CollectStar();
        Destroy(gameObject);
    }
}
