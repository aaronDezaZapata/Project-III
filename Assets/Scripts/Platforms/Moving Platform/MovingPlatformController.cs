using UnityEngine;

public class MovingPlatformController : MonoBehaviour
{
    [Header("Platform Settings")]
    [SerializeField] private Transform _platform;
    [SerializeField] private float _speed = 2f;

    [Header("Waypoints")]
    [SerializeField] private Transform[] _waypoints;

    private int _currentWaypointIndex;
    private bool _movingForward = true;

    private void Start()
    {
        _platform.transform.position = _waypoints[0].position;
    }

    private void Update()
    {
        if (_waypoints == null || _waypoints.Length == 0 || _platform == null)
            return;

        MovePlatform();
    }

    private void MovePlatform()
    {
        Transform targetWaypoint = _waypoints[_currentWaypointIndex];

        _platform.position = Vector3.MoveTowards(
            _platform.position,
            targetWaypoint.position,
            _speed * Time.deltaTime
        );

        if (Vector3.Distance(_platform.position, targetWaypoint.position) < 0.01f)
        {
            _currentWaypointIndex++;

            if (_currentWaypointIndex >= _waypoints.Length)
                _currentWaypointIndex = 0;
        }
    }

    private void OnDrawGizmos()
    {
        if (_waypoints == null || _waypoints.Length == 0)
            return;

        Gizmos.color = Color.yellow;

        for (int i = 0; i < _waypoints.Length; i++)
        {
            if (_waypoints[i] == null)
                continue;

            Gizmos.DrawWireSphere(_waypoints[i].position, 0.3f);

            int nextIndex = (i + 1) % _waypoints.Length;
            if (_waypoints[nextIndex] != null)
                Gizmos.DrawLine(_waypoints[i].position, _waypoints[nextIndex].position);
        }
    }
}
