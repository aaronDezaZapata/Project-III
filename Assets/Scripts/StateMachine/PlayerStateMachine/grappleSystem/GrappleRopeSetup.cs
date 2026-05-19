using UnityEngine;

[ExecuteInEditMode]
public class GrappleRopeSetup : MonoBehaviour
{
    [Header("Auto Setup")]
    [SerializeField] private PlayerStateMachine playerStateMachine;
    
    [Header("Rope Visual Settings")]
    [SerializeField] private Color ropeColor = new Color(0.2f, 1f, 0.3f, 1f); // Verde brillante
    [SerializeField] private float ropeWidth = 0.05f;
    [SerializeField] private Material ropeMaterial;
    
    private void Reset()
    {
        playerStateMachine = GetComponent<PlayerStateMachine>();
    }

#if UNITY_EDITOR
    [ContextMenu("Setup Grapple Rope")]
    private void SetupGrappleRope()
    {
        if (playerStateMachine == null) return;

        Transform ropeTransform = transform.Find("GrappleRope");
        GameObject ropeObject;
        
        if (ropeTransform == null)
        {
            ropeObject = new GameObject("GrappleRope");
            ropeObject.transform.SetParent(transform);
            ropeObject.transform.localPosition = Vector3.zero;
        }
        else
            ropeObject = ropeTransform.gameObject;
        

        LineRenderer lineRenderer = ropeObject.GetComponent<LineRenderer>();
        
        if (lineRenderer == null)
            lineRenderer = ropeObject.AddComponent<LineRenderer>();

        lineRenderer.positionCount = 2;
        lineRenderer.SetPosition(0, Vector3.zero);
        lineRenderer.SetPosition(1, Vector3.zero);
        lineRenderer.startWidth = ropeWidth;
        lineRenderer.endWidth = ropeWidth;
        lineRenderer.useWorldSpace = true;
        lineRenderer.enabled = false; 

        if (ropeMaterial != null)
            lineRenderer.material = ropeMaterial;
        
        else
        {
            Material defaultMat = new Material(Shader.Find("Sprites/Default"));
            defaultMat.color = ropeColor;
            lineRenderer.material = defaultMat;
        }

        lineRenderer.startColor = ropeColor;
        lineRenderer.endColor = ropeColor;


        Transform originTransform = transform.Find("GrappleRopeOrigin");
        GameObject originObject;
        
        if (originTransform == null)
        {
            originObject = new GameObject("GrappleRopeOrigin");
            originObject.transform.SetParent(transform);
            
            originObject.transform.localPosition = new Vector3(0.3f, 1.2f, 0.5f);
        }
    }

    [ContextMenu("Cleanup Grapple Rope")]
    private void CleanupGrappleRope()
    {
        Transform ropeTransform = transform.Find("GrappleRope");
        
        if (ropeTransform != null)
            DestroyImmediate(ropeTransform.gameObject);
        
        Transform originTransform = transform.Find("GrappleRopeOrigin");
        if (originTransform != null)
            DestroyImmediate(originTransform.gameObject);
    }
#endif
}
