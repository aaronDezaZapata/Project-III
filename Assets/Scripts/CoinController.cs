using UnityEngine;

public class CoinController : MonoBehaviour
{
    public int coinValue = 1;

    public float minPitch = 0.5f;
    public float maxPitch = 2f;
    public AudioClip getCoinSound;

    [Header("Attraction")]
    public float attractionDistance = 6f;
    public float attractionSpeed = 12f;
    public float targetHeight = 1f;
    public GameObject grabParticleSystem;
    private Transform player;
    private bool collected;

    private Renderer[] allRenderers;
    private Animator[] allAnimators;
    private ParticleSystem[] allParticles;
    private Collider[] allColliders;

    private void Start()
    {
        allRenderers = GetComponentsInChildren<Renderer>(true);
        allAnimators = GetComponentsInChildren<Animator>(true);
        allParticles = GetComponentsInChildren<ParticleSystem>(true);
        allColliders = GetComponentsInChildren<Collider>(true);
    }

    private void FixedUpdate()
    {
        if(player == null) return;

        FollowPlayer();
    }

    private void FollowPlayer()
    {
        Vector3 targetPos = player.position + Vector3.up * targetHeight;
        float distance = Vector3.Distance(transform.position, targetPos);

        transform.position = Vector3.MoveTowards(
            transform.position,
            targetPos,
            attractionSpeed * Time.fixedDeltaTime
        );
    }

    private void OnTriggerEnter(Collider other)
    {
        player = other.transform;
    }

    private void OnCollisionEnter(Collision collision)
    {
        GameManager.Instance.AddCoin(coinValue);

        Instantiate(grabParticleSystem, transform.position, Quaternion.identity);
        foreach (Collider c in allColliders)
            c.enabled = false;

        foreach (Renderer r in allRenderers)
            r.enabled = false;

        foreach (Animator a in allAnimators)
            a.enabled = false;

        foreach (ParticleSystem ps in allParticles)
        {
            ps.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            ps.Clear();
        }

        Destroy(gameObject, 0.05f);
    }
}