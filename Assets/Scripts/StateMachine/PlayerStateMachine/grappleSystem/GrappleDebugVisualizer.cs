using UnityEngine;

/// <summary>
/// Script de debug para visualizar información del sistema de gancho en tiempo real.
/// Adjunta esto al Player para debugging durante desarrollo.
/// </summary>
public class GrappleDebugVisualizer : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private PlayerStateMachine playerStateMachine;
    [SerializeField] private bool showDebugInfo = true;
    
    [Header("Gizmo Settings")]
    [SerializeField] private bool showGrappleRange = true;
    [SerializeField] private bool showSwingRadius = true;
    [SerializeField] private bool showNearestPoint = true;
    [SerializeField] private Color rangeColor = new Color(0, 1, 0, 0.2f);
    [SerializeField] private Color swingColor = new Color(0, 1, 1, 0.3f);

    private GrapplePoint nearestPoint;
    private float distanceToNearest;

    private void Reset()
    {
        playerStateMachine = GetComponent<PlayerStateMachine>();
    }

    private void Update()
    {
        if (!showDebugInfo) return;
        
        FindNearestGrapplePoint();
    }

    private void FindNearestGrapplePoint()
    {
        GrapplePoint[] allPoints = FindObjectsByType<GrapplePoint>(FindObjectsSortMode.None);
        nearestPoint = null;
        distanceToNearest = float.MaxValue;
        
        foreach (var point in allPoints)
        {
            if (!point.IsActive) continue;
            
            float distance = Vector3.Distance(transform.position, point.Position);
            if (distance < distanceToNearest)
            {
                distanceToNearest = distance;
                nearestPoint = point;
            }
        }
    }

    private void OnDrawGizmos()
    {
        if (playerStateMachine == null) return;

        // Dibujar rango de detección de gancho
        if (showGrappleRange)
        {
            Gizmos.color = rangeColor;
            Gizmos.DrawWireSphere(transform.position, playerStateMachine.MaxGrappleDistance);
        }

        // Dibujar radio de balanceo si está en estado verde
        if (showSwingRadius && playerStateMachine.GetCurrentState() is PlayerGreenState)
        {
            Gizmos.color = swingColor;
            Gizmos.DrawWireSphere(transform.position, playerStateMachine.SwingRadius);
        }

        // Mostrar línea al punto más cercano
        if (showNearestPoint && nearestPoint != null)
        {
            bool inRange = distanceToNearest <= playerStateMachine.MaxGrappleDistance;
            Gizmos.color = inRange ? Color.green : Color.yellow;
            Gizmos.DrawLine(transform.position, nearestPoint.Position);
            
            // Dibujar esfera en el punto
            Gizmos.DrawWireSphere(nearestPoint.Position, 0.5f);
        }
    }

    private void OnGUI()
    {
        if (!showDebugInfo) return;

        GUILayout.BeginArea(new Rect(10, 10, 300, 400));
        GUILayout.BeginVertical("box");
        
        GUILayout.Label("=== GRAPPLE DEBUG ===");
        GUILayout.Space(10);
        
        State currentState = playerStateMachine?.GetCurrentState();
        string stateName = currentState?.GetType().Name ?? "None";
        GUILayout.Label($"Estado: {stateName}");
        
        if (playerStateMachine?.InputReader != null)
        {
            bool isGreenPressed = playerStateMachine.InputReader.isGreen;
            GUILayout.Label($"Input Verde: {(isGreenPressed ? "PRESIONADO" : "No")}");
        }
        
        GUILayout.Space(10);
        
        if (nearestPoint != null)
        {
            GUILayout.Label("=== PUNTO MÁS CERCANO ===");
            GUILayout.Label($"Nombre: {nearestPoint.gameObject.name}");
            GUILayout.Label($"Distancia: {distanceToNearest:F2}m");
            
            bool inRange = distanceToNearest <= playerStateMachine.MaxGrappleDistance;
            GUILayout.Label($"En Rango: {(inRange ? "SÍ ✓" : "NO ✗")}");
            
            if (inRange)
            {
                GUILayout.Label(">>> PUEDES ENGANCHARTE <<<", 
                    new GUIStyle(GUI.skin.label) { normal = { textColor = Color.green } });
            }
        }
        else
        {
            GUILayout.Label("No hay puntos de enganche en la escena");
        }
        
        GUILayout.Space(10);
        
        // Configuración actual
        if (playerStateMachine != null)
        {
            GUILayout.Label("=== CONFIGURACIÓN ===");
            GUILayout.Label($"Max Distance: {playerStateMachine.MaxGrappleDistance}m");
            GUILayout.Label($"Swing Radius: {playerStateMachine.SwingRadius}m");
            GUILayout.Label($"Has Ability: {playerStateMachine.HasGreenAbility}");
        }
        
        GUILayout.Space(10);
        
        // Información específica del estado verde
        if (currentState is PlayerGreenState)
        {
            GUILayout.Label("=== BALANCEÁNDOSE ===");
            GUILayout.Label("Presiona ESPACIO para saltar");
            GUILayout.Label("Usa WASD para influir en el balanceo");
        }
        
        GUILayout.EndVertical();
        GUILayout.EndArea();
    }

    // Método helper para activar/desactivar debug desde consola
    [ContextMenu("Toggle Debug Info")]
    public void ToggleDebugInfo()
    {
        showDebugInfo = !showDebugInfo;
        Debug.Log($"Grapple Debug Info: {(showDebugInfo ? "ON" : "OFF")}");
    }
}
