using UnityEngine;

[RequireComponent(typeof(Rigidbody), typeof(Collider))]
public class InkProjectile : MonoBehaviour
{
    public int hitsToDie;
    private int currentHits;
        
    [SerializeField] private LayerMask decalLayerMask = ~0;
    
    private PlayerStateMachine stateMachine;
    private bool done;
    
    public void Initialize(PlayerStateMachine machineRef)
    {
        stateMachine = machineRef;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (done) return;
    
        // Paint surface or destroy after X number of hits
        if ((decalLayerMask.value & (1 << collision.gameObject.layer)) == 0)
        {
            /*currentHits++;
            if (currentHits >= hitsToDie)
            {
                Destroy(gameObject);
            }*/
            Destroy(gameObject);
            return;
        }

        ContactPoint cp = collision.GetContact(0);
        
        if (stateMachine != null)
        {
            stateMachine.PaintSurface(cp.point, cp.normal);
        }
        
        done = true;
        Destroy(gameObject);
    }
}
