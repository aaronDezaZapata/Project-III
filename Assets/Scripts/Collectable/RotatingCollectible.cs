using UnityEngine;

public class RotatingCollectible : MonoBehaviour
{
    [Header("Rotation")]
    [SerializeField] private float _rotationSpeed = 120f;
    [SerializeField] private Vector3 _rotationAxis = Vector3.up;

    [Header("Collection")]
    [SerializeField] private string _playerTag = "Player";

    [Header("Optional")]
    [SerializeField] private GameObject _collectVFX;

    private void Update()
    {
        transform.Rotate(_rotationAxis * _rotationSpeed * Time.deltaTime, Space.Self);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag(_playerTag)) return;
        Collect();
    }

    private void Collect()
    {
        if (_collectVFX != null)
            Instantiate(_collectVFX, transform.position, Quaternion.identity);

        Destroy(gameObject);
    }
}
