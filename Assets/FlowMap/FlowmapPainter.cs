using UnityEngine;
using System.Collections.Generic;

namespace FlowmapTools
{
    [RequireComponent(typeof(MeshFilter))]
    public class FlowmapPainter : MonoBehaviour
    {
        [Header("Flowmap Settings")]
        [SerializeField] private int textureResolution = 512;
        [SerializeField] private Texture2D flowmapTexture;
        
        [Header("Paint Settings")]
        [Range(0.1f, 5f)]
        public float brushSize = 1f;
        [Range(0f, 1f)]
        public float brushStrength = 0.5f;
        [Range(0f, 1f)]
        public float brushFalloff = 0.5f;
        
        [Header("Flow Direction")]
        public Vector3 flowDirection = Vector3.forward;
        [Range(0f, 1f)]
        public float flowSpeed = 0.5f;
        
        [Header("Visualization")]
        public bool showFlowVectors = true;
        public float vectorScale = 0.5f;
        public Color vectorColor = Color.cyan;
        
        // Runtime data
        private Mesh mesh;
        private Vector3[] vertices;
        private Vector2[] uvs;
        private Color[] flowData; // RG = flow direction, B = flow speed, A = unused
        
        public Mesh Mesh => mesh;
        public Vector3[] Vertices => vertices;
        public Vector2[] UVs => uvs;
        public Color[] FlowData => flowData;
        public Texture2D FlowmapTexture => flowmapTexture;
        
        private void OnValidate()
        {
            InitializeMeshData();
        }
        
        public void InitializeMeshData()
        {
            MeshFilter meshFilter = GetComponent<MeshFilter>();
            if (meshFilter == null || meshFilter.sharedMesh == null)
                return;
                
            mesh = meshFilter.sharedMesh;
            vertices = mesh.vertices;
            uvs = mesh.uv;
            
            // Initialize flow data if needed
            if (flowData == null || flowData.Length != vertices.Length)
            {
                flowData = new Color[vertices.Length];
                // Initialize with neutral flow (pointing down the river)
                for (int i = 0; i < flowData.Length; i++)
                {
                    flowData[i] = new Color(0.5f, 0.5f, 0.5f, 1f);
                }
            }
        }
        
        public void PaintAtPosition(Vector3 worldPos, Vector3 direction, float strength)
        {
            if (vertices == null || flowData == null)
            {
                InitializeMeshData();
                if (vertices == null) return;
            }
            
            // Convert direction to tangent space and encode
            Vector3 localDir = transform.InverseTransformDirection(direction.normalized);
            
            for (int i = 0; i < vertices.Length; i++)
            {
                Vector3 worldVertex = transform.TransformPoint(vertices[i]);
                float distance = Vector3.Distance(worldPos, worldVertex);
                
                if (distance < brushSize)
                {
                    // Calculate brush influence with falloff
                    float influence = 1f - (distance / brushSize);
                    influence = Mathf.Pow(influence, 1f + brushFalloff * 3f);
                    influence *= strength * brushStrength;
                    
                    // Encode flow direction (tangent space)
                    Vector2 flowDir = new Vector2(localDir.x, localDir.z).normalized;
                    Color targetFlow = new Color(
                        flowDir.x * 0.5f + 0.5f, // Remap from -1,1 to 0,1
                        flowDir.y * 0.5f + 0.5f,
                        flowSpeed,
                        1f
                    );
                    
                    // Blend with existing flow data
                    flowData[i] = Color.Lerp(flowData[i], targetFlow, influence);
                }
            }
        }
        
        public void BakeToTexture()
        {
            if (flowData == null || uvs == null)
            {
                Debug.LogError("No flow data to bake!");
                return;
            }
            
            // Create texture if it doesn't exist
            if (flowmapTexture == null)
            {
                flowmapTexture = new Texture2D(textureResolution, textureResolution, TextureFormat.RGBA32, false, true);
                flowmapTexture.wrapMode = TextureWrapMode.Clamp;
                flowmapTexture.filterMode = FilterMode.Bilinear;
            }
            else if (flowmapTexture.width != textureResolution)
            {
                flowmapTexture.Reinitialize(textureResolution, textureResolution);
            }
            
            // Clear texture
            Color[] pixels = new Color[textureResolution * textureResolution];
            for (int i = 0; i < pixels.Length; i++)
            {
                pixels[i] = new Color(0.5f, 0.5f, 0.5f, 1f);
            }
            
            // Rasterize vertex data to texture using UVs
            for (int i = 0; i < uvs.Length; i++)
            {
                int x = Mathf.RoundToInt(uvs[i].x * (textureResolution - 1));
                int y = Mathf.RoundToInt(uvs[i].y * (textureResolution - 1));
                
                x = Mathf.Clamp(x, 0, textureResolution - 1);
                y = Mathf.Clamp(y, 0, textureResolution - 1);
                
                int index = y * textureResolution + x;
                pixels[index] = flowData[i];
                
                // Splat to neighbors for better coverage
                SplatPixel(pixels, x, y, flowData[i], textureResolution);
            }
            
            // Fill holes with nearest neighbor
            FillHoles(pixels, textureResolution);
            
            flowmapTexture.SetPixels(pixels);
            flowmapTexture.Apply();
            
            Debug.Log($"Flowmap baked to texture: {textureResolution}x{textureResolution}");
        }
        
        private void SplatPixel(Color[] pixels, int x, int y, Color color, int resolution)
        {
            for (int dy = -1; dy <= 1; dy++)
            {
                for (int dx = -1; dx <= 1; dx++)
                {
                    int nx = x + dx;
                    int ny = y + dy;
                    
                    if (nx >= 0 && nx < resolution && ny >= 0 && ny < resolution)
                    {
                        int index = ny * resolution + nx;
                        pixels[index] = Color.Lerp(pixels[index], color, 0.5f);
                    }
                }
            }
        }
        
        private void FillHoles(Color[] pixels, int resolution)
        {
            Color neutralColor = new Color(0.5f, 0.5f, 0.5f, 1f);
            
            for (int y = 0; y < resolution; y++)
            {
                for (int x = 0; x < resolution; x++)
                {
                    int index = y * resolution + x;
                    
                    // If pixel is still neutral, try to fill from neighbors
                    if (Vector4.Distance(pixels[index], neutralColor) < 0.01f)
                    {
                        Color average = Color.clear;
                        int count = 0;
                        
                        for (int dy = -1; dy <= 1; dy++)
                        {
                            for (int dx = -1; dx <= 1; dx++)
                            {
                                if (dx == 0 && dy == 0) continue;
                                
                                int nx = x + dx;
                                int ny = y + dy;
                                
                                if (nx >= 0 && nx < resolution && ny >= 0 && ny < resolution)
                                {
                                    int nIndex = ny * resolution + nx;
                                    if (Vector4.Distance(pixels[nIndex], neutralColor) > 0.01f)
                                    {
                                        average += pixels[nIndex];
                                        count++;
                                    }
                                }
                            }
                        }
                        
                        if (count > 0)
                        {
                            pixels[index] = average / count;
                        }
                    }
                }
            }
        }
        
        public void ClearFlowmap()
        {
            if (flowData != null)
            {
                for (int i = 0; i < flowData.Length; i++)
                {
                    flowData[i] = new Color(0.5f, 0.5f, 0.5f, 1f);
                }
            }
            
            if (flowmapTexture != null)
            {
                Color[] pixels = flowmapTexture.GetPixels();
                for (int i = 0; i < pixels.Length; i++)
                {
                    pixels[i] = new Color(0.5f, 0.5f, 0.5f, 1f);
                }
                flowmapTexture.SetPixels(pixels);
                flowmapTexture.Apply();
            }
        }
        
        public void SaveTexture(string path)
        {
            if (flowmapTexture == null)
            {
                Debug.LogError("No texture to save!");
                return;
            }
            
            byte[] bytes = flowmapTexture.EncodeToPNG();
            System.IO.File.WriteAllBytes(path, bytes);
            Debug.Log($"Flowmap saved to: {path}");
            
            #if UNITY_EDITOR
            UnityEditor.AssetDatabase.Refresh();
            #endif
        }
    }
}
