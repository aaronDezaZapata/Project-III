using UnityEditor;
using UnityEngine;

public class ReplaceObjectsTool
{
    [MenuItem("Tools/Replace Selected With New %#r")]
    static void ReplaceSelected()
    {
        if (Selection.activeGameObject == null) return;

        GameObject newPrefab = Selection.activeGameObject;

        foreach (GameObject obj in Selection.gameObjects)
        {
            if (obj == newPrefab) continue;

            GameObject newObj = Object.Instantiate(newPrefab);
            newObj.transform.position = obj.transform.position;
            newObj.transform.rotation = obj.transform.rotation;
            newObj.transform.localScale = obj.transform.localScale;

            Undo.RegisterCreatedObjectUndo(newObj, "Replace Objects");
            Undo.DestroyObjectImmediate(obj);
        }
    }
}