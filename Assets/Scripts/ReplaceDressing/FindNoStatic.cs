using UnityEngine;
using UnityEditor;

public class SceneStaticScanner
{
    [MenuItem("Tools/Select All Non-Static Objects")]
    static void SelectNonStatic()
    {
        GameObject[] allObjects =
            Object.FindObjectsByType<GameObject>(FindObjectsSortMode.None);

        var result = new System.Collections.Generic.List<GameObject>();

        foreach (var obj in allObjects)
        {
            if (!obj.activeInHierarchy) continue;

            if (!obj.isStatic)
                result.Add(obj);
        }

        Selection.objects = result.ToArray();

        Debug.Log($"Selected non-static objects: {result.Count}");
    }
}