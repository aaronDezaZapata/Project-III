using UnityEngine;

public class DestructibleGlass : MonoBehaviour
{
    [SerializeField] GameObject brokenObject;

    private void OnCollisionEnter(Collision collision)
    {
       if(collision.transform.CompareTag("Enemy"))
        {
            brokenObject.SetActive(true);
            Destroy(gameObject);
        }
    }
}
