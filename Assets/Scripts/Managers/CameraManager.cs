using UnityEngine;
using Unity.Cinemachine;

public class CameraManager : MonoBehaviour
{
    public static CameraManager Instance { get; private set; }

    [SerializeField] private CinemachineOrbitalFollow _orbital;
    [SerializeField] private float _swimRadius = 5f;

    private float _normalRadiusTop;
    private float _normalRadiusCenter;
    private float _normalRadiusBottom;

    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
        {
            Destroy(this);
            return;
        }

        if (_orbital == null)
            _orbital = GameManager.Instance.GetPlayer().GetComponentInChildren<CinemachineOrbitalFollow>();

        _normalRadiusTop    = _orbital.Orbits.Top.Radius;
        _normalRadiusCenter = _orbital.Orbits.Center.Radius;
        _normalRadiusBottom = _orbital.Orbits.Bottom.Radius;
    }

    public void ChangeCameraSwimming(bool isSwimming)
    {
        if (isSwimming)
        {
            _orbital.Orbits.Top.Radius    += _swimRadius;
            _orbital.Orbits.Center.Radius += _swimRadius;
            _orbital.Orbits.Bottom.Radius += _swimRadius;
        }
        else
        {
            _orbital.Orbits.Top.Radius    = _normalRadiusTop;
            _orbital.Orbits.Center.Radius = _normalRadiusCenter;
            _orbital.Orbits.Bottom.Radius = _normalRadiusBottom;
        }
    }
}
