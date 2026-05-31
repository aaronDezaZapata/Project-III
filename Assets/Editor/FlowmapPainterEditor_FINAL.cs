using UnityEngine;
using UnityEditor;

namespace FlowmapTools
{
    [CustomEditor(typeof(FlowmapPainter))]
    public class FlowmapPainterEditor : Editor
    {
        private FlowmapPainter painter;
        private bool isPainting = false;
        private Vector3 lastPaintPos;
        private Vector3 initialPaintPos;
        
        private enum PaintMode
        {
            Paint,
            Erase,
            Smooth
        }
        
        private PaintMode paintMode = PaintMode.Paint;
        
        private void OnEnable()
        {
            painter = (FlowmapPainter)target;
            painter.InitializeMeshData();
            
            // Subscribe to scene view events
            SceneView.duringSceneGui += OnSceneGUI;
        }
        
        private void OnDisable()
        {
            SceneView.duringSceneGui -= OnSceneGUI;
        }
        
        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Flowmap Painter", EditorStyles.boldLabel);
            EditorGUILayout.HelpBox("Hold Shift + Left Mouse and DRAG to paint flow direction in Scene view. The flow will follow your brush movement direction.", MessageType.Info);
            
            EditorGUILayout.Space();
            
            // Paint Mode
            EditorGUILayout.LabelField("Paint Mode", EditorStyles.boldLabel);
            paintMode = (PaintMode)EditorGUILayout.EnumPopup("Mode", paintMode);
            
            EditorGUILayout.Space();
            
            // Draw default inspector
            DrawDefaultInspector();
            
            EditorGUILayout.Space();
            
            // Auto-Generation Section
            EditorGUILayout.LabelField("Auto-Generation", EditorStyles.boldLabel);
            EditorGUILayout.HelpBox("Auto-generate flow based on mesh vertex progression. Works well for rivers that flow primarily in one direction.", MessageType.Info);
            
            if (GUILayout.Button("Auto-Generate Flow from Mesh", GUILayout.Height(30)))
            {
                if (EditorUtility.DisplayDialog("Auto-Generate Flow",
                    "This will overwrite existing flow data. Continue?",
                    "Generate", "Cancel"))
                {
                    AutoGenerateFlow();
                }
            }
            
            EditorGUILayout.Space();
            
            // Buttons
            EditorGUILayout.LabelField("Actions", EditorStyles.boldLabel);
            
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("Bake to Texture", GUILayout.Height(30)))
            {
                painter.BakeToTexture();
                EditorUtility.SetDirty(painter);
            }
            
            if (GUILayout.Button("Clear Flowmap", GUILayout.Height(30)))
            {
                if (EditorUtility.DisplayDialog("Clear Flowmap", 
                    "Are you sure you want to clear all painted flow data?", 
                    "Clear", "Cancel"))
                {
                    painter.ClearFlowmap();
                    EditorUtility.SetDirty(painter);
                }
            }
            EditorGUILayout.EndHorizontal();
            
            if (painter.FlowmapTexture != null)
            {
                if (GUILayout.Button("Save Texture to File", GUILayout.Height(30)))
                {
                    string path = EditorUtility.SaveFilePanel(
                        "Save Flowmap Texture",
                        "Assets",
                        painter.gameObject.name + "_Flowmap.png",
                        "png"
                    );
                    
                    if (!string.IsNullOrEmpty(path))
                    {
                        painter.SaveTexture(path);
                    }
                }
                
                EditorGUILayout.Space();
                EditorGUILayout.LabelField("Preview", EditorStyles.boldLabel);
                
                Rect rect = GUILayoutUtility.GetRect(256, 256);
                EditorGUI.DrawPreviewTexture(rect, painter.FlowmapTexture);
            }
            
            serializedObject.ApplyModifiedProperties();
            
            if (GUI.changed)
            {
                SceneView.RepaintAll();
            }
        }
        
        #region Auto Generation
        private void AutoGenerateFlow()
        {
            if (painter.Vertices == null || painter.Vertices.Length == 0)
            {
                Debug.LogError("No mesh data available!");
                return;
            }
            
            // Analyze mesh to find dominant flow direction
            Vector3 meshBounds = GetMeshBounds();
            Vector3 dominantAxis = GetDominantAxis(meshBounds);
            
            Debug.Log($"Detected dominant flow axis: {dominantAxis}");
            
            // Generate flow data based on vertex progression
            Color[] flowData = new Color[painter.Vertices.Length];
            
            for (int i = 0; i < painter.Vertices.Length; i++)
            {
                Vector3 localPos = painter.Vertices[i];
                Vector3 flowDirection;
                
                // Try to find neighboring vertices to calculate actual flow direction
                flowDirection = CalculateLocalFlowDirection(i, dominantAxis);
                
                // Encode to flowmap color
                Vector2 flowDir2D = new Vector2(flowDirection.x, flowDirection.z).normalized;
                Color flowColor = new Color(
                    flowDir2D.x * 0.5f + 0.5f,
                    flowDir2D.y * 0.5f + 0.5f,
                    painter.flowSpeed, // Use painter's flow speed setting
                    1f
                );
                
                flowData[i] = flowColor;
            }
            
            // Apply to painter
            System.Array.Copy(flowData, painter.FlowData, flowData.Length);
            
            EditorUtility.SetDirty(painter);
            Debug.Log("Auto-generated flow data from mesh geometry!");
        }
        
        private Vector3 GetMeshBounds()
        {
            Vector3 min = painter.Vertices[0];
            Vector3 max = painter.Vertices[0];
            
            foreach (Vector3 v in painter.Vertices)
            {
                min = Vector3.Min(min, v);
                max = Vector3.Max(max, v);
            }
            
            return max - min;
        }
        
        private Vector3 GetDominantAxis(Vector3 bounds)
        {
            // Find which axis the river flows along
            float absX = Mathf.Abs(bounds.x);
            float absZ = Mathf.Abs(bounds.z);
            
            if (absX > absZ)
            {
                return new Vector3(Mathf.Sign(bounds.x), 0, 0);
            }
            else
            {
                return new Vector3(0, 0, Mathf.Sign(bounds.z));
            }
        }
        
        private Vector3 CalculateLocalFlowDirection(int index, Vector3 fallbackDirection)
        {
            Vector3 currentPos = painter.Vertices[index];
            Vector3 flowDir = Vector3.zero;
            int samples = 0;
            
            // Look at nearby vertices to determine local flow
            float searchRadius = 1.0f;
            
            for (int i = 0; i < painter.Vertices.Length; i++)
            {
                if (i == index) continue;
                
                float distance = Vector3.Distance(currentPos, painter.Vertices[i]);
                
                if (distance < searchRadius && distance > 0.01f)
                {
                    Vector3 toNeighbor = (painter.Vertices[i] - currentPos).normalized;
                    
                    // Weight by alignment with dominant direction
                    float alignment = Vector3.Dot(toNeighbor, fallbackDirection);
                    
                    if (alignment > 0)
                    {
                        flowDir += toNeighbor * alignment;
                        samples++;
                    }
                }
            }
            
            if (samples > 0)
            {
                flowDir = (flowDir / samples).normalized;
            }
            else
            {
                flowDir = fallbackDirection;
            }
            
            // Flatten to XZ plane
            flowDir.y = 0;
            return flowDir.normalized;
        }
        #endregion
        
        private void OnSceneGUI(SceneView sceneView)
        {
            if (painter == null) return;
            
            Event e = Event.current;
            
            // Check for paint hotkey (Shift + Left Mouse)
            bool shouldPaint = e.shift && e.type == EventType.MouseDrag && e.button == 0;
            bool paintStart = e.shift && e.type == EventType.MouseDown && e.button == 0;
            
            if (shouldPaint || paintStart)
            {
                // Prevent normal selection
                int controlID = GUIUtility.GetControlID(FocusType.Passive);
                HandleUtility.AddDefaultControl(controlID);
                
                // Raycast to find paint position
                Ray ray = HandleUtility.GUIPointToWorldRay(e.mousePosition);
                RaycastHit hit;
                
                if (Physics.Raycast(ray, out hit))
                {
                    if (hit.collider.gameObject == painter.gameObject || 
                        hit.collider.transform.IsChildOf(painter.transform))
                    {
                        Vector3 paintPos = hit.point;
                        
                        if (paintStart)
                        {
                            lastPaintPos = paintPos;
                            initialPaintPos = paintPos;
                            isPainting = true;
                        }
                        
                        if (isPainting && shouldPaint)
                        {
                            // Calculate flow direction from brush movement
                            Vector3 direction = (paintPos - lastPaintPos).normalized;
                            
                            // Only paint if there's actual movement
                            if (direction.magnitude > 0.001f)
                            {
                                // Paint with the movement direction
                                float strength = paintMode == PaintMode.Erase ? -1f : 1f;
                                painter.PaintAtPosition(paintPos, direction, strength);
                                
                                lastPaintPos = paintPos;
                                
                                EditorUtility.SetDirty(painter);
                                SceneView.RepaintAll();
                            }
                        }
                        
                        e.Use();
                    }
                }
            }
            
            if (e.type == EventType.MouseUp)
            {
                isPainting = false;
            }
            
            // Draw brush preview
            if (e.shift && e.type == EventType.MouseMove)
            {
                Ray ray = HandleUtility.GUIPointToWorldRay(e.mousePosition);
                RaycastHit hit;
                
                if (Physics.Raycast(ray, out hit))
                {
                    // Draw brush circle
                    Handles.color = new Color(0, 1, 1, 0.3f);
                    Handles.DrawSolidDisc(hit.point, hit.normal, painter.brushSize);
                    
                    Handles.color = Color.cyan;
                    Handles.DrawWireDisc(hit.point, hit.normal, painter.brushSize);
                    
                    SceneView.RepaintAll();
                }
            }
            
            // Draw flow vectors
            if (painter.showFlowVectors && painter.FlowData != null)
            {
                DrawFlowVectors();
            }
        }
        
        private void DrawFlowVectors()
        {
            if (painter.Vertices == null || painter.FlowData == null) return;
            
            Handles.color = painter.vectorColor;
            
            // Only draw every Nth vertex to avoid cluttering
            int step = Mathf.Max(1, painter.Vertices.Length / 200);
            
            for (int i = 0; i < painter.Vertices.Length; i += step)
            {
                Vector3 worldPos = painter.transform.TransformPoint(painter.Vertices[i]);
                
                // Decode flow direction from color
                Color flowColor = painter.FlowData[i];
                Vector2 flowDir = new Vector2(
                    (flowColor.r - 0.5f) * 2f,
                    (flowColor.g - 0.5f) * 2f
                );
                
                Vector3 localFlow = new Vector3(flowDir.x, 0, flowDir.y).normalized;
                Vector3 worldFlow = painter.transform.TransformDirection(localFlow);
                
                float flowMagnitude = flowColor.b;
                Vector3 endPos = worldPos + worldFlow * painter.vectorScale * flowMagnitude;
                
                // Draw arrow
                Handles.DrawLine(worldPos, endPos);
                
                // Draw arrowhead
                Vector3 right = Vector3.Cross(worldFlow, Vector3.up).normalized * 0.1f * painter.vectorScale;
                Vector3 arrowTip = endPos;
                Vector3 arrowBase = endPos - worldFlow * 0.2f * painter.vectorScale;
                
                Handles.DrawLine(arrowTip, arrowBase + right);
                Handles.DrawLine(arrowTip, arrowBase - right);
            }
        }
        
        [MenuItem("GameObject/Effects/Flowmap Painter", false, 10)]
        static void CreateFlowmapPainter()
        {
            GameObject go = new GameObject("FlowmapPainter");
            go.AddComponent<FlowmapPainter>();
            Selection.activeGameObject = go;
            Undo.RegisterCreatedObjectUndo(go, "Create Flowmap Painter");
        }
    }
}
