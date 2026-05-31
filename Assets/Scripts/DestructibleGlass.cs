using UnityEngine;

public class DestructibleGlass : MonoBehaviour
{
    [SerializeField] private GameObject _brokenObject;

    private void OnCollisionEnter(Collision collision)
    {
        if (!collision.transform.CompareTag("Enemy")) return;

        _brokenObject.SetActive(true);
        Destroy(gameObject);
    }
}
