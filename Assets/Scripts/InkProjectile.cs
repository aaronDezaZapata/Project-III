using UnityEngine;

[RequireComponent(typeof(Rigidbody), typeof(Collider))]
public class InkProjectile : MonoBehaviour
{
    private InkDecalPainter painter;
    private LayerMask mask;
    private bool done;

    public void Init(InkDecalPainter painterRef, LayerMask paintableMask)
    {
        painter = painterRef;
        mask = paintableMask;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (done) return;
        if (((1 << collision.gameObject.layer) & mask) == 0) return;

        ContactPoint cp = collision.GetContact(0);
        painter?.Paint(cp.point, cp.normal);

        done = true;
        Destroy(gameObject);
    }
}
