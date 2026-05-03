using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

public class FindConvexMeshColliders : EditorWindow
{
    [MenuItem("Tools/Find Convex MeshColliders")]
    public static void ShowWindow()
    {
        GetWindow<FindConvexMeshColliders>("Convex MeshColliders");
    }

    private void OnGUI()
    {
        GUILayout.Label("Find MeshColliders (Convex = true)", EditorStyles.boldLabel);

        if (GUILayout.Button("Select All Convex MeshColliders"))
        {
            FindAndSelect();
        }
    }

    private void FindAndSelect()
    {
        MeshCollider[] allColliders = GameObject.FindObjectsOfType<MeshCollider>();

        List<GameObject> results = new List<GameObject>();

        foreach (MeshCollider col in allColliders)
        {
            if (col.convex)
            {
                results.Add(col.gameObject);
            }
        }

        Selection.objects = results.ToArray();

        Debug.Log($"Encontrados {results.Count} MeshColliders con Convex activado.");
    }
}