using UnityEditor;
using UnityEngine;

public class ReplaceObjectsTool
{
    [MenuItem("Tools/Replace Selected %#r")]
    static void ReplaceSelected()
    {
        var selected = Selection.gameObjects;
        if (selected.Length < 2) return;

        GameObject source = Selection.activeGameObject;

        var sourceMF = source.GetComponentInChildren<MeshFilter>();
        if (sourceMF == null) return;

        Vector3 sourceSize = sourceMF.sharedMesh.bounds.size;

        foreach (var obj in selected)
        {
            if (obj == source) continue;

            var oldMF = obj.GetComponentInChildren<MeshFilter>();
            if (oldMF == null) continue;

            Vector3 oldSize = oldMF.sharedMesh.bounds.size;

            var parent = obj.transform.parent;

            GameObject instance = (GameObject)PrefabUtility.InstantiatePrefab(source);
            if (instance == null)
                instance = Object.Instantiate(source);

            instance.transform.SetParent(parent, false);

            instance.transform.localPosition = obj.transform.localPosition;
            instance.transform.localRotation = obj.transform.localRotation;

            Vector3 factor = new Vector3(
                oldSize.x / sourceSize.x,
                oldSize.y / sourceSize.y,
                oldSize.z / sourceSize.z
            );

            instance.transform.localScale = Vector3.Scale(obj.transform.localScale, factor);

            Undo.RegisterCreatedObjectUndo(instance, "Replace");
            Undo.DestroyObjectImmediate(obj);
        }
    }
}
