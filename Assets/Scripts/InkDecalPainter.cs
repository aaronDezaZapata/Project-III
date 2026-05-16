using UnityEngine;

public class InkDecalPainter : MonoBehaviour
{
    [SerializeField] private GameObject inkDecalPrefab;
    [SerializeField] private float surfaceOffset = 0.01f;
    [SerializeField] private Vector3 decalFixEuler = new Vector3(90f, 0f, 0f);

    public void Paint(Vector3 point, Vector3 normal)
    {
        if (inkDecalPrefab == null) return;

        Quaternion alignmentRotation = Quaternion.FromToRotation(Vector3.up, normal);
        Quaternion fixRotation = Quaternion.Euler(decalFixEuler);
        Quaternion finalRotation = alignmentRotation * fixRotation;

        GameObject splat = Instantiate(inkDecalPrefab, point, finalRotation);
        splat.transform.position += normal * surfaceOffset;
    }
}
