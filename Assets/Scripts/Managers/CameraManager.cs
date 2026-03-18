using UnityEngine;
using Unity.Cinemachine;

public class CameraManager : MonoBehaviour
{
    public static CameraManager Instance;

    public float normalRadiusTop = 3f;
    public float normalRadiusCenter = 3f;
    public float normalRadiusBottom = 3f;

    public float swimRadius = 5f;

    public CinemachineOrbitalFollow orbital;
    float targetRadius;

    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(this);
            return;
        }

        if(orbital == null)
        {
            orbital = GameManager.Instance.GetPlayer().GetComponentInChildren<CinemachineOrbitalFollow>();
        }
        

        normalRadiusTop = orbital.Orbits.Top.Radius;
        normalRadiusCenter = orbital.Orbits.Center.Radius; 
        normalRadiusBottom = orbital.Orbits.Bottom.Radius;
    }

   
    public void ChangeCameraSwimming(bool isSwimming)
    {
        if (isSwimming)
        {
            orbital.Orbits.Top.Radius+= swimRadius ;
            orbital.Orbits.Center.Radius += swimRadius;
            orbital.Orbits.Bottom.Radius += swimRadius;
        }
        else
        {
            orbital.Orbits.Top.Radius = normalRadiusTop;
            orbital.Orbits.Center.Radius = normalRadiusCenter;
            orbital.Orbits.Bottom.Radius = normalRadiusBottom;

        }
    }
}
