using UnityEngine;

public class LookAtPlayerInRange : MonoBehaviour
{
    [SerializeField] private float rotationSpeed = 5f;
    [SerializeField] private bool rotateX;
    [SerializeField] private bool rotateY = true;
    [SerializeField] private bool rotateZ;
    
    private Transform _player;
    private Quaternion _initialRotation;
    private bool _playerInRange;

    private void Awake()
    {
        _initialRotation = transform.rotation;
    }

    private void Update()
    {
        if (!_playerInRange && Quaternion.Angle(transform.rotation, _initialRotation) < 0.01f) return;

        Quaternion target = _playerInRange ? GetLookRotation() : _initialRotation;
        transform.rotation = Quaternion.Slerp(transform.rotation, target, rotationSpeed * Time.deltaTime);
    }

    private void OnTriggerEnter(Collider other)
    {
        _player = other.transform;
        _playerInRange = true;
    }

    private void OnTriggerExit(Collider other)
    {
        _player = null;
        _playerInRange = false;
    }

    private Quaternion GetLookRotation()
    {
        Vector3 direction = _player.position - transform.position;
        if (direction == Vector3.zero) return transform.rotation;

        Vector3 targetEuler = Quaternion.LookRotation(direction).eulerAngles;
        Vector3 currentEuler = transform.rotation.eulerAngles;

        return Quaternion.Euler(
            rotateX ? targetEuler.x : currentEuler.x,
            rotateY ? targetEuler.y : currentEuler.y,
            rotateZ ? targetEuler.z : currentEuler.z
        );
    }
}
