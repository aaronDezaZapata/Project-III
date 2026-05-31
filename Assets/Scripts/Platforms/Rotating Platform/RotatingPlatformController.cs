using UnityEngine;

public class RotatingPlatformController : MonoBehaviour
{
    public enum RotationAxis { X, Y, Z }

    [SerializeField] private RotationAxis _axis;
    [SerializeField] private float _speed = 2f;
    [SerializeField] private GameObject _platform;

    private void Update()
    {
        switch (_axis)
        {
            case RotationAxis.X:
                _platform.transform.Rotate(Vector3.right * _speed * Time.deltaTime);
                break;
            case RotationAxis.Y:
                _platform.transform.Rotate(Vector3.up * _speed * Time.deltaTime);
                break;
            case RotationAxis.Z:
                _platform.transform.Rotate(Vector3.forward * _speed * Time.deltaTime);
                break;
        }
    }
}
