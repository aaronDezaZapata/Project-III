using UnityEngine;

public class ObjectPainter : MonoBehaviour
{
    [Tooltip("The Prefab to be painted onto the scene.")]
    public GameObject prefabToPaint;

    [Tooltip("The radius of the circular brush.")]
    [Range(0.1f, 20f)]
    public float brushRadius = 2.0f;

    [Tooltip("The number of objects to spawn per click/drag within the brush radius. Higher values mean more density.")]
    [Range(1, 50)]
    public int brushDensity = 5;

    [Tooltip("An optional parent to place the spawned objects under. Helps keep the hierarchy clean.")]
    public Transform parentTransform;
}
