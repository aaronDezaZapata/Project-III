#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using System.IO;

public class MissingScriptCleaner
{
    [MenuItem("Tools/Clean Missing Scripts/Scene + Prefabs")]
    static void CleanAll()
    {
        int totalRemoved = 0;

        Scene scene = SceneManager.GetActiveScene();
        GameObject[] rootObjects = scene.GetRootGameObjects();
        foreach (GameObject root in rootObjects)
        {
            totalRemoved += CleanGameObjectRecursive(root);
        }
        EditorSceneManager.MarkSceneDirty(scene);
        Debug.Log("Scene cleaned.");

        string[] prefabGUIDs = AssetDatabase.FindAssets("t:Prefab");
        foreach (string guid in prefabGUIDs)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            GameObject prefab = PrefabUtility.LoadPrefabContents(path);
            if (prefab == null)
                continue;

            int removed = CleanGameObjectRecursive(prefab);
            if (removed > 0)
            {
                totalRemoved += removed;
                PrefabUtility.SaveAsPrefabAsset(prefab, path);
                Debug.Log($"Cleaned prefab: {path} ({removed} removed)");
            }
            PrefabUtility.UnloadPrefabContents(prefab);
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log($"DONE. Removed {totalRemoved} missing scripts.");
    }

    static int CleanGameObjectRecursive(GameObject go)
    {
        int removed = 0;
        removed += GameObjectUtility.RemoveMonoBehavioursWithMissingScript(go);
        foreach (Transform child in go.transform)
        {
            removed += CleanGameObjectRecursive(child.gameObject);
        }
        return removed;
    }
}
#endif