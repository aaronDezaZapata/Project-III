using UnityEngine;

public class CoinController : MonoBehaviour
{
    [SerializeField] private int _coinValue = 1;

    [Header("Attraction")]
    [SerializeField] private float _attractionDistance = 6f;
    [SerializeField] private float _attractionSpeed    = 12f;
    [SerializeField] private float _targetHeight       = 1f;
    [SerializeField] private GameObject _grabParticleSystem;

    private Transform _player;
    private bool _isCollected;

    private Renderer[] _allRenderers;
    private Animator[] _allAnimators;
    private ParticleSystem[] _allParticles;
    private Collider[] _allColliders;

    private void Start()
    {
        GameObject playerObj = GameObject.FindGameObjectWithTag("Player");
        if (playerObj != null)
            _player = playerObj.transform;

        _allRenderers = GetComponentsInChildren<Renderer>(true);
        _allAnimators = GetComponentsInChildren<Animator>(true);
        _allParticles = GetComponentsInChildren<ParticleSystem>(true);
        _allColliders = GetComponentsInChildren<Collider>(true);
    }

    private void FixedUpdate()
    {
        if (_isCollected || _player == null) return;

        Vector3 targetPos = _player.position + Vector3.up * _targetHeight;
        float distance    = Vector3.Distance(transform.position, targetPos);

        if (distance <= _attractionDistance)
        {
            transform.position = Vector3.MoveTowards(
                transform.position,
                targetPos,
                _attractionSpeed * Time.fixedDeltaTime
            );
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (_isCollected || !other.CompareTag("Player")) return;

        _isCollected = true;
        
        GameManager.Instance.AddCoin(_coinValue);
        Instantiate(_grabParticleSystem, transform.position, Quaternion.identity);

        foreach (Collider c in _allColliders)
            c.enabled = false;

        foreach (Renderer r in _allRenderers)
            r.enabled = false;

        foreach (Animator a in _allAnimators)
            a.enabled = false;

        foreach (ParticleSystem ps in _allParticles)
        {
            ps.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            ps.Clear();
        }
        
        AudioManager.Instance.PlayCoinGet();

        Destroy(gameObject, 0.05f);
    }
}
