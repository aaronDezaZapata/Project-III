using UnityEngine;

public class ThrownObjectImpact : MonoBehaviour
{
    [SerializeField] private float _minImpactSpeed = 4f;

    private PlayerAudio _playerAudio;
    private Rigidbody   _rigidbody;
    private bool        _hasPlayed;

    public void Initialize(PlayerAudio audio, float minSpeed = 4f)
    {
        _playerAudio    = audio;
        _minImpactSpeed = minSpeed;
    }

    private void Awake()
    {
        _rigidbody = GetComponent<Rigidbody>();
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (_hasPlayed || _rigidbody == null) return;
        if (_rigidbody.linearVelocity.magnitude < _minImpactSpeed) return;

        Vector3 impactPoint = collision.contacts.Length > 0
            ? collision.contacts[0].point
            : transform.position;

        _playerAudio?.PlayObjectImpact(impactPoint);
        _hasPlayed = true;

        Destroy(this, 0.05f);
    }
}
