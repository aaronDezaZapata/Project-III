using Unity.Cinemachine;
using UnityEngine;

public class AimCameraSwitcher : MonoBehaviour
{
    [SerializeField] private SurfaceAimReticle aimReticle;

    [SerializeField] private CinemachineCamera normalCam;
    [SerializeField] private CinemachineCamera aimCam;

    [SerializeField] private int normalPriority = 10;
    [SerializeField] private int aimPriority = 20;

    private void Awake()
    {
        if (aimReticle == null) aimReticle = FindFirstObjectByType<SurfaceAimReticle>();
    }

    private void OnEnable()
    {
        if (aimReticle != null) aimReticle.OnAimChanged += Apply;
    }

    private void OnDisable()
    {
        if (aimReticle != null) aimReticle.OnAimChanged -= Apply;
    }

    private void Start() => Apply(false);

    private void Apply(bool isAiming)
    {
        if (normalCam != null) normalCam.Priority = isAiming ? normalPriority : aimPriority;
        if (aimCam != null) aimCam.Priority = isAiming ? aimPriority : normalPriority;
    }
}
