using UnityEngine;

public class ThrownObjectImpact : MonoBehaviour
{
    [SerializeField] private float minImpactSpeed = 4f;

    private PlayerAudio playerAudio;
    private Rigidbody rb;
    private bool hasPlayed;

    public void Initialize(PlayerAudio audio, float minSpeed = 4f)
    {
        playerAudio = audio;
        minImpactSpeed = minSpeed;
    }

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (hasPlayed) return;
        if (rb == null) return;
        if (rb.linearVelocity.magnitude < minImpactSpeed) return;

        Vector3 impactPoint = collision.contacts.Length > 0
            ? collision.contacts[0].point
            : transform.position;

        playerAudio?.PlayObjectImpact(impactPoint);
        hasPlayed = true;

        Destroy(this, 0.05f);
    }
}