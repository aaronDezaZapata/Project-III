using UnityEngine;

/// <summary>
/// Script helper para configurar automáticamente el visual de la cuerda del gancho.
/// Adjunta este script al Player y presiona el botón "Setup Grapple Rope" en el Inspector.
/// </summary>
[ExecuteInEditMode]
public class GrappleRopeSetup : MonoBehaviour
{
    [Header("Auto Setup")]
    [SerializeField] private PlayerStateMachine playerStateMachine;
    
    [Header("Rope Visual Settings")]
    [SerializeField] private Color ropeColor = new Color(0.2f, 1f, 0.3f, 1f); // Verde brillante
    [SerializeField] private float ropeWidth = 0.05f;
    [SerializeField] private Material ropeMaterial;
    
    [Header("Info")]
    [SerializeField] private bool setupComplete = false;

    private void Reset()
    {
        playerStateMachine = GetComponent<PlayerStateMachine>();
    }

#if UNITY_EDITOR
    [ContextMenu("Setup Grapple Rope")]
    private void SetupGrappleRope()
    {
        if (playerStateMachine == null)
        {
            Debug.LogError("PlayerStateMachine no encontrado. Asigna la referencia primero.");
            return;
        }

        Transform ropeTransform = transform.Find("GrappleRope");
        GameObject ropeObject;
        
        if (ropeTransform == null)
        {
            ropeObject = new GameObject("GrappleRope");
            ropeObject.transform.SetParent(transform);
            ropeObject.transform.localPosition = Vector3.zero;
            Debug.Log("✓ GameObject 'GrappleRope' creado");
        }
        else
        {
            ropeObject = ropeTransform.gameObject;
            Debug.Log("✓ GameObject 'GrappleRope' ya existe");
        }

        LineRenderer lineRenderer = ropeObject.GetComponent<LineRenderer>();
        if (lineRenderer == null)
        {
            lineRenderer = ropeObject.AddComponent<LineRenderer>();
            Debug.Log("✓ LineRenderer añadido");
        }

        lineRenderer.positionCount = 2;
        lineRenderer.SetPosition(0, Vector3.zero);
        lineRenderer.SetPosition(1, Vector3.zero);
        lineRenderer.startWidth = ropeWidth;
        lineRenderer.endWidth = ropeWidth;
        lineRenderer.useWorldSpace = true;
        lineRenderer.enabled = false; 

        if (ropeMaterial != null)
        {
            lineRenderer.material = ropeMaterial;
        }
        else
        {
            Material defaultMat = new Material(Shader.Find("Sprites/Default"));
            defaultMat.color = ropeColor;
            lineRenderer.material = defaultMat;
            Debug.Log("✓ Material por defecto creado");
        }

        lineRenderer.startColor = ropeColor;
        lineRenderer.endColor = ropeColor;

        Debug.Log("✓ LineRenderer configurado correctamente");

        Transform originTransform = transform.Find("GrappleRopeOrigin");
        GameObject originObject;
        
        if (originTransform == null)
        {
            originObject = new GameObject("GrappleRopeOrigin");
            originObject.transform.SetParent(transform);
            
            originObject.transform.localPosition = new Vector3(0.3f, 1.2f, 0.5f);
            
            Debug.Log("✓ 'GrappleRopeOrigin' creado. Ajusta su posición a la mano del personaje.");
        }
        else
        {
            originObject = originTransform.gameObject;
            Debug.Log("✓ 'GrappleRopeOrigin' ya existe");
        }

        try
        {
            var grappleRopeProp = playerStateMachine.GetType().GetProperty("GrappleRope");
            var grappleOriginProp = playerStateMachine.GetType().GetProperty("GrappleRopeOrigin");

            if (grappleRopeProp != null && grappleOriginProp != null)
            {
                Debug.Log("✓ Referencias asignadas. Verifica en el Inspector de PlayerStateMachine.");
            }
            else
            {
                Debug.LogWarning("No se encontraron las propiedades GrappleRope/GrappleRopeOrigin. " +
                                "Asígnalas manualmente en el Inspector de PlayerStateMachine.");
            }
        }
        catch
        {
            Debug.LogWarning("Asigna manualmente el LineRenderer y el Origin en PlayerStateMachine.");
        }

        Debug.Log("====================================");
        Debug.Log("SETUP COMPLETO!");
        Debug.Log("====================================");
        Debug.Log("PASOS SIGUIENTES:");
        Debug.Log("1. Arrastra el GameObject 'GrappleRope' al campo 'Grapple Rope' en PlayerStateMachine");
        Debug.Log("2. Arrastra el GameObject 'GrappleRopeOrigin' al campo 'Grapple Rope Origin'");
        Debug.Log("3. Ajusta la posición de 'GrappleRopeOrigin' para que coincida con la mano de tu personaje");
        Debug.Log("4. (Opcional) Asigna un material personalizado al LineRenderer");
        Debug.Log("====================================");

        setupComplete = true;
    }

    [ContextMenu("Cleanup Grapple Rope")]
    private void CleanupGrappleRope()
    {
        Transform ropeTransform = transform.Find("GrappleRope");
        if (ropeTransform != null)
        {
            DestroyImmediate(ropeTransform.gameObject);
            Debug.Log("✓ GrappleRope eliminado");
        }

        Transform originTransform = transform.Find("GrappleRopeOrigin");
        if (originTransform != null)
        {
            DestroyImmediate(originTransform.gameObject);
            Debug.Log("✓ GrappleRopeOrigin eliminado");
        }

        setupComplete = false;
        Debug.Log("Cleanup completo");
    }
#endif
}
