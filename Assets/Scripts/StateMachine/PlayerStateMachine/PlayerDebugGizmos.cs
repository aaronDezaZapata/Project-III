using UnityEngine;

public class PlayerDebugGizmos : MonoBehaviour
{
    private PlayerStateMachine _player;

    private void Awake()
    {
        _player = GetComponent<PlayerStateMachine>();
    }

    private void OnDrawGizmosSelected()
    {
        if (_player == null)
            _player = GetComponent<PlayerStateMachine>();

        if (_player == null || _player.groundCheckOrigin == null) return;

        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(_player.groundCheckOrigin.position, _player.groundCheckRadius);

        Vector3 castDirection = Vector3.down * _player.groundCheckDistance;
        Vector3 endPosition = _player.groundCheckOrigin.position + castDirection;

        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(endPosition, _player.groundCheckRadius);

        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(_player.groundCheckOrigin.position, endPosition);

        if (Application.isPlaying)
        {
            if (Physics.SphereCast(
                _player.groundCheckOrigin.position,
                _player.groundCheckRadius,
                Vector3.down,
                out RaycastHit hit,
                _player.groundCheckDistance,
                _player.groundMask
            ))
            {
                Gizmos.color = Color.red;
                Gizmos.DrawSphere(hit.point, 0.05f);
            }
        }
    }
}
