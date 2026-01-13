using UnityEngine;

[RequireComponent(typeof(Rigidbody), typeof(Collider))]
public class InkProjectile : MonoBehaviour
{
    
    private PlayerStateMachine stateMachine;
    private LayerMask mask;
    private bool done;

    
    public void Initialize(PlayerStateMachine machineRef)
    {
        stateMachine = machineRef;
        
        mask = machineRef.PaintableLayer;
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
        if (((1 << collision.gameObject.layer) & mask) == 0) return;

        ContactPoint cp = collision.GetContact(0);

        
        if (stateMachine != null)
        {
            stateMachine.PaintSurface(cp.point, cp.normal);
        }

        done = true;
        Destroy(gameObject);
    }
}
