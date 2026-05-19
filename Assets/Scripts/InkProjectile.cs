using UnityEngine;

[RequireComponent(typeof(Rigidbody), typeof(Collider))]
public class InkProjectile : MonoBehaviour
{
    [SerializeField] private int _hitsToDie;
    [SerializeField] private LayerMask _decalLayerMask = ~0;

    private PlayerStateMachine _stateMachine;
    private int  _currentHits;
    private bool _hasImpacted;

    public void Initialize(PlayerStateMachine machineRef)
    {
        _stateMachine = machineRef;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (_hasImpacted) return;

        if ((_decalLayerMask.value & (1 << collision.gameObject.layer)) == 0)
        {
            Destroy(gameObject);
            return;
        }

        ContactPoint cp = collision.GetContact(0);

        if (_stateMachine != null)
        {
            _stateMachine.PaintSurface(cp.point, cp.normal);
            _stateMachine.PlayerAudio?.PlayPaintSurfaceImpact();
        }

        _hasImpacted = true;
        Destroy(gameObject);
    }
}
