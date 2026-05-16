using UnityEngine;

public class FruitPathFollower : MonoBehaviour
{
    [System.Serializable]
    public class SpeedRange
    {
        [Tooltip("Starting point index for this range")]
        public int startPointIndex;

        [Tooltip("Ending point index for this range")]
        public int endPointIndex = 1;

        [Tooltip("Target speed in this segment")]
        public float targetSpeed = 5f;

        [Tooltip("How fast the speed accelerates toward the target")]
        public float acceleration = 2f;
    }

    [SerializeField] private FruitPath _path;

    [Header("Movement")]
    [SerializeField] private float _baseSpeed          = 3f;
    [SerializeField] private float _rotationSpeed      = 8f;
    [SerializeField] private float _pointReachDistance = 0.2f;
    [SerializeField] private bool  _destroyAtEnd       = true;

    [Header("Bobbing")]
    [SerializeField] private float _bobHeight = 0.3f;
    [SerializeField] private float _bobSpeed  = 2f;
    [SerializeField] private float _tiltAmount = 8f;
    [SerializeField] private float _tiltSpeed  = 2f;

    [Header("Speed Ranges")]
    [SerializeField] private SpeedRange[] _speedRanges;

    private float _currentSpeed;
    private int   _currentPointIndex;
    private Vector3 _basePosition;
    private float _randomOffset;

    public void SetPath(FruitPath newPath)
    {
        _path              = newPath;
        _currentPointIndex = 0;
        _randomOffset      = Random.Range(0f, 100f);
        _currentSpeed      = _baseSpeed;

        if (_path != null && _path.PointCount > 0)
        {
            transform.position = _path.GetPoint(0);
            _basePosition      = transform.position;
        }
    }

    private void Start()
    {
        _randomOffset = Random.Range(0f, 100f);
        _currentSpeed = _baseSpeed;

        if (_path != null && _path.PointCount > 0)
            _basePosition = transform.position;
    }

    private void Update()
    {
        if (_path == null || _path.PointCount == 0) return;
        if (_currentPointIndex >= _path.PointCount) return;

        UpdateSpeedByRange();

        Vector3 target        = _path.GetPoint(_currentPointIndex);
        Vector3 flatDirection = target - _basePosition;

        if (flatDirection.magnitude <= _pointReachDistance)
        {
            _currentPointIndex++;

            if (_currentPointIndex >= _path.PointCount)
            {
                if (_destroyAtEnd) Destroy(gameObject);
                return;
            }

            target        = _path.GetPoint(_currentPointIndex);
            flatDirection = target - _basePosition;
        }

        Vector3 moveDir = flatDirection.normalized;
        _basePosition  += moveDir * _currentSpeed * Time.deltaTime;

        float bobOffset = Mathf.Sin((Time.time + _randomOffset) * _bobSpeed) * _bobHeight;
        transform.position = _basePosition + Vector3.up * bobOffset;

        if (moveDir != Vector3.zero)
        {
            Quaternion lookRot  = Quaternion.LookRotation(moveDir);
            float tiltZ         = Mathf.Sin((Time.time + _randomOffset) * _tiltSpeed) * _tiltAmount;
            Quaternion tiltRot  = Quaternion.Euler(0f, 0f, tiltZ);

            transform.rotation = Quaternion.Slerp(
                transform.rotation,
                lookRot * tiltRot,
                _rotationSpeed * Time.deltaTime
            );
        }
    }

    private void UpdateSpeedByRange()
    {
        float targetSpeed = _baseSpeed;
        float accel       = 999f;

        if (_speedRanges != null)
        {
            foreach (SpeedRange range in _speedRanges)
            {
                if (range == null) continue;

                if (_currentPointIndex >= range.startPointIndex && _currentPointIndex <= range.endPointIndex)
                {
                    targetSpeed = range.targetSpeed;
                    accel       = range.acceleration;
                    break;
                }
            }
        }

        _currentSpeed = Mathf.MoveTowards(_currentSpeed, targetSpeed, accel * Time.deltaTime);
    }
}
