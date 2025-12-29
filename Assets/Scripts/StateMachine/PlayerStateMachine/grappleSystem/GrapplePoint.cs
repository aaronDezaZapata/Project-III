using UnityEngine;

/// <summary>
/// Marca un punto en el mundo donde el jugador puede engancharse con el gancho verde.
/// Attach este componente a cualquier GameObject que quieras que sea un punto de enganche.
/// </summary>
public class GrapplePoint : MonoBehaviour
{
    [Header("Visual Feedback")]
    [SerializeField] private bool showGizmo = true;
    [SerializeField] private Color gizmoColor = Color.green;
    [SerializeField] private float gizmoRadius = 0.5f;

    [Header("Point Info")]
    [Tooltip("Si está activo, el jugador puede engancharse a este punto")]
    [SerializeField] private bool isActive = true;

    public bool IsActive => isActive;
    public Vector3 Position => transform.position;

    /// <summary>
    /// Activa o desactiva este punto de enganche
    /// </summary>
    public void SetActive(bool active)
    {
        isActive = active;
    }

    private void OnDrawGizmos()
    {
        if (!showGizmo) return;

        Gizmos.color = isActive ? gizmoColor : Color.gray;
        Gizmos.DrawWireSphere(transform.position, gizmoRadius);
        
        // Dibuja una cruz para mejor visualización
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
