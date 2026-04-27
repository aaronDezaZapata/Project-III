using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

[ExecuteAlways]
public class SceneObjectIdentifier : MonoBehaviour
{
    public string UniqueID;
    [HideInInspector]
    public bool hasUnsyncedChanges = false;

    private bool _lockedByNetwork = false;

    private void Awake()
    {
        ValidateID();
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        EditorApplication.delayCall += ValidateID;
    }
#endif

    public void SetNetworkID(string id)
    {
        _lockedByNetwork = true;
        UniqueID = id;
        hasUnsyncedChanges = false;
#if UNITY_EDITOR
        EditorApplication.delayCall += () => { _lockedByNetwork = false; };
#endif
    }

    public void ValidateID()
    {
        if (this == null) return;
        if (IsPrefabAsset()) return;

        // En runtime no hacemos nada de esto
#if UNITY_EDITOR
        if (Application.isPlaying) return;
#endif

        bool generateNew = false;

        if (string.IsNullOrEmpty(UniqueID))
        {
            generateNew = true;
        }
        else if (IsDuplicate(UniqueID))
        {
            generateNew = true;
        }

        if (generateNew)
        {
            string oldID = UniqueID;
            GenerateID();

#if UNITY_EDITOR
            if (!string.IsNullOrEmpty(oldID))
                Debug.Log($"[Collab] Clon detectado. ID cambiado: {oldID} -> {UniqueID}");

            if (SceneSyncManager.Instance != null)
                SceneSyncManager.Instance.UploadNewObject(this.gameObject);
#endif
        }
    }

    private bool IsDuplicate(string idToCheck)
    {
#if UNITY_EDITOR
        if (Application.isPlaying) return false;

        var allIdentifiers = FindObjectsOfType<SceneObjectIdentifier>();
        foreach (var other in allIdentifiers)
        {
            if (other != this && other.UniqueID == idToCheck)
                return true;
        }
#endif
        return false;
    }

    public void GenerateID()
    {
        UniqueID = System.Guid.NewGuid().ToString();
        hasUnsyncedChanges = true;
#if UNITY_EDITOR
        if (!Application.isPlaying) EditorUtility.SetDirty(this);
#endif
    }

    private bool IsPrefabAsset()
    {
#if UNITY_EDITOR
        return this.gameObject.scene.rootCount == 0 || this.gameObject.scene.name == null;
#else
        return false;
#endif
    }
}