using UnityEngine;

public class GrapplePoint : MonoBehaviour
{
    [Header("Visual Feedback")]
    [SerializeField] private bool showGizmo = true;
    [SerializeField] private Color gizmoColor = Color.green;
    [SerializeField] private float gizmoRadius = 0.5f;

    [Header("Point Info")]
    [SerializeField] private bool isActive = true;

    public bool IsActive => isActive;
    public Vector3 Position => transform.position;

    public void SetActive(bool active)
    {
        isActive = active;
    }

    private void OnDrawGizmos()
    {
        if (!showGizmo) return;

        Gizmos.color = isActive ? gizmoColor : Color.gray;
        Gizmos.DrawWireSphere(transform.position, gizmoRadius);
        
        Gizmos.DrawLine(
            transform.position + Vector3.up * gizmoRadius,
            transform.position - Vector3.up * gizmoRadius
        );
        Gizmos.DrawLine(
            transform.position + Vector3.right * gizmoRadius,
            transform.position - Vector3.right * gizmoRadius
        );
    }
}
