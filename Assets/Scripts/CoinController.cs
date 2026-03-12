using UnityEngine;

public class CoinController : MonoBehaviour
{
    public int coinValue;

    private void OnTriggerEnter(Collider other)
    {
        GameManager.Instance.AddCoin(coinValue);
        
        Destroy(gameObject);
    }
}
