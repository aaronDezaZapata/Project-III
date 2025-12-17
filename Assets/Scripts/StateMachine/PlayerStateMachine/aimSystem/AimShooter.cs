using UnityEngine;

#if ENABLE_INPUT_SYSTEM
using UnityEngine.InputSystem;
#endif

public class AimShooter : MonoBehaviour
{
    [Header("Refs")]
    [SerializeField] private SurfaceAimReticle aimReticle;
    [SerializeField] private Transform firePoint;
    [SerializeField] private Rigidbody projectilePrefab;

    [Header("Parabola")]
    [Tooltip("Altura extra del arco por encima del punto más alto entre origen y objetivo.")]
    [SerializeField] private float arcHeight = 2.0f;

    [Header("Fire")]
    [SerializeField] private float fireCooldown = 0.15f;
    [SerializeField] private bool onlyFireWhileAiming = true;

    [Header("Speed")]
    [SerializeField] private float flightTime = 0.6f;

    [Header("Paint On Impact")]
    [SerializeField] private InkDecalPainter painter;
    [SerializeField] private LayerMask paintableMask = ~0;

    [Header("Ignore Self Collision (opcional)")]
    [SerializeField] private Transform ignoreCollidersRoot;
    private Collider[] selfColliders;


    private float nextFireTime;

    private void Awake()
    {
        if (aimReticle == null) aimReticle = FindFirstObjectByType<SurfaceAimReticle>();

        if (painter == null) painter = FindFirstObjectByType<InkDecalPainter>();

        if (ignoreCollidersRoot != null)
            selfColliders = ignoreCollidersRoot.GetComponentsInChildren<Collider>();
    }

    private void Update()
    {
        if (Time.time < nextFireTime) return;

        if (onlyFireWhileAiming && (aimReticle == null || !aimReticle.IsAiming))
            return;

        if (!IsFireHeld()) return;

        if (aimReticle == null || firePoint == null || projectilePrefab == null) return;

        if (!aimReticle.TryGetAimHit(out Vector3 aimPoint, out _))
            return;

        FireParabolaTowards(aimPoint);
        nextFireTime = Time.time + fireCooldown;
    }

    private void FireParabolaTowards(Vector3 targetPoint)
    {
        Vector3 origin = firePoint.position;

        if (!TryGetBallisticVelocityByFlightTime(origin, targetPoint, flightTime, out Vector3 v0))
            return;

        Rigidbody rb = Instantiate(projectilePrefab, origin, Quaternion.identity);

        // Para tiro parabólico:
        rb.useGravity = true;
        rb.linearDamping = 0f;
        rb.angularDamping = 0f;
        rb.linearVelocity = v0;

        InkProjectile inkProj = rb.GetComponent<InkProjectile>();
        if (inkProj != null)
        {
            inkProj.Init(painter, paintableMask);
        }
        if (selfColliders != null)
        {
            Collider projCol = rb.GetComponent<Collider>();
            if (projCol != null)
                foreach (var c in selfColliders)
                    if (c != null) Physics.IgnoreCollision(projCol, c, true);
        }
    }

    /// <summary>
    /// Calcula velocidad inicial para llegar al target con una parabola.
    /// </summary>
    private bool TryGetBallisticVelocityByFlightTime(Vector3 origin, Vector3 target, float time, out Vector3 velocity)
    {
        float g = Physics.gravity.y; // normalmente negativo
        time = Mathf.Max(0.05f, time);

        Vector3 delta = target - origin;

        // Vxz = distancia horizontal / tiempo
        Vector3 deltaXZ = new Vector3(delta.x, 0f, delta.z);
        Vector3 vXZ = deltaXZ / time;

        // Vy llegar a misma altura definida a mano en el tiempo con gravedad
        float vY = (delta.y - 0.5f * g * time * time) / time;

        velocity = vXZ + Vector3.up * vY;
        return true;
    }

    private bool IsFireHeld()
    {
        bool held = false;

#if ENABLE_INPUT_SYSTEM
        if (Mouse.current != null) held |= Mouse.current.leftButton.isPressed;
#endif

#if ENABLE_LEGACY_INPUT_MANAGER
        held |= Input.GetMouseButton(0);
#endif

        return held;
    }

}
