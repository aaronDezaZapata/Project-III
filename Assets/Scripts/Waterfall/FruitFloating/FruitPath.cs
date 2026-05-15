using UnityEngine;

public class FruitPath : MonoBehaviour
{
    public Transform[] points;

    public Vector3 GetPoint(int index)
    {
        return points[index].position;
    }

    public int PointCount => points.Length;

    private void OnDrawGizmos()
    {
        if (points == null || points.Length < 2) return;

        Gizmos.color = Color.cyan;

        for (int i = 0; i < points.Length - 1; i++)
        {
            if (points[i] != null && points[i + 1] != null)
            {
                Gizmos.DrawLine(points[i].position, points[i + 1].position);
                Gizmos.DrawSphere(points[i].position, 0.2f);
            }
        }

        Gizmos.DrawSphere(points[points.Length - 1].position, 0.2f);
    }
}