using UnityEngine;

[RequireComponent(typeof(Rigidbody), typeof(Collider))]
public class InkProjectile : MonoBehaviour
{
    private PlayerStateMachine stateMachine;
    [SerializeField] private LayerMask decalLayerMask = ~0;
    private bool done;

    
    public void Initialize(PlayerStateMachine machineRef)
    {
        stateMachine = machineRef;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (done) return;
    
        // Enemy detection
        EnemyStateMachine enemyStateMachine = collision.gameObject.GetComponent<EnemyStateMachine>();
        if (enemyStateMachine != null)
        {
            PaintableEnemy paintable = collision.gameObject.GetComponent<PaintableEnemy>();
            if (paintable == null)
            {
                paintable = collision.gameObject.AddComponent<PaintableEnemy>();
            }

            paintable.ApplyPaint();
        }
        
        // Paint surface
        if ((decalLayerMask.value & (1 << collision.gameObject.layer)) == 0) return;

        ContactPoint cp = collision.GetContact(0);

        
        if (stateMachine != null)
        {
            stateMachine.PaintSurface(cp.point, cp.normal);
        }

        done = true;
        Destroy(gameObject);
    }
}
