using UnityEngine;

public class FruitPath : MonoBehaviour
{
    [SerializeField] private Transform[] _points;

    public int PointCount => _points.Length;

    public Vector3 GetPoint(int index)
    {
        return _points[index].position;
    }

    private void OnDrawGizmos()
    {
        if (_points == null || _points.Length < 2) return;

        Gizmos.color = Color.cyan;

        for (int i = 0; i < _points.Length - 1; i++)
        {
            if (_points[i] != null && _points[i + 1] != null)
            {
                Gizmos.DrawLine(_points[i].position, _points[i + 1].position);
                Gizmos.DrawSphere(_points[i].position, 0.2f);
            }
        }

        Gizmos.DrawSphere(_points[_points.Length - 1].position, 0.2f);
    }
}
