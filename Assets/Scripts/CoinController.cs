using UnityEngine;

public class CoinController : MonoBehaviour
{
    public int coinValue;
    
    public float minPitch = 0.5f;
    
    public float maxPitch = 2f;

    public AudioClip getCoinSound;

    private void OnTriggerEnter(Collider other)
    {
        GameManager.Instance.AddCoin(coinValue);
        
        SoundFXManager.Instance.PlaySoundFXClipRandPitch(getCoinSound, transform, 1f, minPitch, maxPitch);
        
        Destroy(gameObject);
    }
}
