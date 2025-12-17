using System;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class PlayerShootingState : PlayerBaseState
{
    public PlayerShootingState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    [Header("References")]
    [SerializeField] private Camera aimCamera;
    [SerializeField] private Transform reticle; // Quad o Canvas

    [Header("Raycast")]
    [SerializeField] private float maxDistance = 80f;
    [SerializeField] private LayerMask aimMask = ~0;
    [SerializeField] private bool useScreenCenter = true; //cursor looked
    [SerializeField] private bool useSphereCast = true;
    [SerializeField] private float sphereRadius = 0.08f;
    [SerializeField] private float surfaceOffset = 0.01f;
    [SerializeField] private bool hideIfNoHit = true;

    [Header("Visual")]
    [SerializeField] private bool scaleWithDistance = true;
    [SerializeField] private float worldSizeAt1m = 0.08f;
    [SerializeField] private bool flipForward = false;
    [SerializeField] private Vector3 extraEulerRotation = Vector3.zero;

    public bool IsAiming { get; private set; }

    private bool hasAimHit;
    private Vector3 lastAimPoint;
    private Vector3 lastAimNormal;

    public override void Enter()
    {
        IsAiming = stateMachine.InputReader.isAiming;
        if (aimCamera == null) aimCamera = Camera.main;

        

    }

    public override void Tick(float deltaTime)
    {


        if (stateMachine.InputReader.isAiming == false)
        { stateMachine.SwitchState(typeof(PlayerFreeLookState)); }


        Ray ray = useScreenCenter
           ? aimCamera.ViewportPointToRay(new Vector3(0.5f, 0.5f, 0f))
           : aimCamera.ScreenPointToRay(Input.mousePosition);

        bool hitSomething = Cast(ray, out RaycastHit hit);

        if (!hitSomething)
        {
            hasAimHit = false;
            if (hideIfNoHit) SetVisible(false);
            return;
        }

        PlaceReticle(hit);


    }

    public override void Exit()
    {
       
    }



    private void SetVisible(bool visible)
    {
        if (reticle != null && reticle.gameObject.activeSelf != visible)
            reticle.gameObject.SetActive(visible);
    }

    public bool TryGetAimHit(out Vector3 point, out Vector3 normal)
    {
        point = lastAimPoint;
        normal = lastAimNormal;
        return hasAimHit;
    }

    void AimPlayer()
    {
 
        SetVisible(IsAiming);
    }


    private bool Cast(Ray ray, out RaycastHit hit)
    {
        if (useSphereCast)
        {
            return Physics.SphereCast(ray, sphereRadius, out hit, maxDistance, aimMask, QueryTriggerInteraction.Ignore);
        }
        return Physics.Raycast(ray, out hit, maxDistance, aimMask, QueryTriggerInteraction.Ignore);
    }

    private void PlaceReticle(RaycastHit hit)
    {
        hasAimHit = true;
        lastAimPoint = hit.point;
        lastAimNormal = hit.normal;

        SetVisible(true);

        Vector3 normal = hit.normal;
        Vector3 forward = flipForward ? -normal : normal;

        // Pos pegada a superficie con offset peque
        reticle.position = hit.point + normal * surfaceOffset;

        Vector3 up = Vector3.ProjectOnPlane(aimCamera.transform.up, normal);
        if (up.sqrMagnitude < 0.0001f)
            up = Vector3.ProjectOnPlane(aimCamera.transform.right, normal);

        Quaternion rot = Quaternion.LookRotation(forward, up.normalized);
        rot *= Quaternion.Euler(extraEulerRotation);
        reticle.rotation = rot;

        if (scaleWithDistance)
        {
            float d = Vector3.Distance(aimCamera.transform.position, hit.point);
            float s = worldSizeAt1m * Mathf.Max(0.01f, d);
            reticle.localScale = Vector3.one * s;
        }
    }
}
