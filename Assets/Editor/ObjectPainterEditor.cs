using UnityEngine;
using UnityEditor;

/// <summary>
/// This is the custom editor script that creates the brush functionality in the Scene View.
/// This script MUST be placed in a folder named "Editor".
/// </summary>
[CustomEditor(typeof(ObjectPainter))]
public class ObjectPainterEditor : Editor
{
    private ObjectPainter objectPainter;

    void OnEnable()
    {
        // Get the target component this editor is inspecting.
        objectPainter = (ObjectPainter)target;
    }

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        EditorGUILayout.HelpBox("Hold down Left Ctrl and use the Left Mouse Button to paint objects.\nHold down Left Ctrl + Left Shift and use the Left Mouse Button to erase objects.", MessageType.Info);
    }

    void OnSceneGUI()
    {
        Event currentEvent = Event.current;
        int controlID = GUIUtility.GetControlID(FocusType.Passive);

        // Make our tool the default control for the scene view when Ctrl is held.
        if (currentEvent.type == EventType.Layout && currentEvent.control)
        {
            HandleUtility.AddDefaultControl(controlID);
            return;
        }

        // Only process events if the Ctrl key is held down.
        if (!currentEvent.control)
        {
            return;
        }

        // Create a ray from the mouse position into the scene.
        Ray worldRay = HandleUtility.GUIPointToWorldRay(currentEvent.mousePosition);
        if (Physics.Raycast(worldRay, out RaycastHit hitInfo))
        {
            bool isErasing = currentEvent.shift;

            // Change brush color based on mode (Paint vs Erase)
            Handles.color = isErasing ? Color.red : Color.cyan;
            Handles.DrawWireDisc(hitInfo.point, hitInfo.normal, objectPainter.brushRadius);
            Handles.color = isErasing ? new Color(1, 0, 0, 0.1f) : new Color(0, 1, 1, 0.1f);
            Handles.DrawSolidDisc(hitInfo.point, hitInfo.normal, objectPainter.brushRadius);

            // Check if the user is clicking or dragging the left mouse button.
            if ((currentEvent.type == EventType.MouseDown || currentEvent.type == EventType.MouseDrag) && currentEvent.button == 0)
            {
                // **This is the critical part that prevents selection**
                // We "use" the event so Unity's default selection logic ignores it.
                currentEvent.Use();

                if (isErasing)
                {
                    EraseObjects(hitInfo.point);
                }
                else
                {
                    PaintObjects(hitInfo.point, hitInfo.normal);
                }
            }
        }

        // Repaint the scene to ensure the brush circle is updated in real-time as you move the mouse.
        SceneView.RepaintAll();
    }

    /// <summary>
    /// Erases objects within the brush radius.
    /// </summary>
    /// <param name="centerPosition">The center of the brush.</param>
    private void EraseObjects(Vector3 centerPosition)
    {
        // This check is important to prevent accidentally deleting parts of your scene.
        // Erasing will only work on objects that are children of the specified Parent Transform.
        if (objectPainter.parentTransform == null)
        {
            Debug.LogWarning("Cannot erase objects without a Parent Transform assigned. This is needed to identify which objects to remove.");
            return;
        }

        // Find all colliders within the brush radius
        Collider[] colliders = Physics.OverlapSphere(centerPosition, objectPainter.brushRadius);

        foreach (var collider in colliders)
        {
            // Check if the collider's transform is a child of our designated parent
            if (collider.transform.IsChildOf(objectPainter.parentTransform))
            {
                // Use Undo.DestroyObjectImmediate for editor script object deletion, so it can be undone.
                Undo.DestroyObjectImmediate(collider.gameObject);
            }
        }
    }

    private void PaintObjects(Vector3 centerPosition, Vector3 surfaceNormal)
    {
        if (objectPainter.prefabToPaint == null)
        {
            Debug.LogWarning("No prefab selected to paint. Please assign a prefab in the ObjectPainter component.");
            return;
        }

        for (int i = 0; i < objectPainter.brushDensity; i++)
        {
            Quaternion surfaceRotation = Quaternion.FromToRotation(Vector3.up, surfaceNormal);
            Vector2 randomPoint2D = Random.insideUnitCircle * objectPainter.brushRadius;
            Vector3 spawnOffset = new Vector3(randomPoint2D.x, 0, randomPoint2D.y);
            Vector3 rotatedOffset = surfaceRotation * spawnOffset;
            Vector3 spawnPosition = centerPosition + rotatedOffset;

            if (Physics.Raycast(spawnPosition + surfaceNormal * 10f, -surfaceNormal, out RaycastHit placementHit, 20f))
            {
                GameObject newObject = (GameObject)PrefabUtility.InstantiatePrefab(objectPainter.prefabToPaint);
                if (newObject == null)
                {
                    Debug.LogError("Failed to instantiate prefab. Please ensure it's a valid prefab and you are in Edit Mode.");
                    continue;
                }

                newObject.transform.position = placementHit.point;
                newObject.transform.rotation = Quaternion.FromToRotation(Vector3.up, placementHit.normal);

                if (objectPainter.parentTransform != null)
                {
                    newObject.transform.SetParent(objectPainter.parentTransform);
                }

                Undo.RegisterCreatedObjectUndo(newObject, "Paint Object");
            }
        }
    }
}

