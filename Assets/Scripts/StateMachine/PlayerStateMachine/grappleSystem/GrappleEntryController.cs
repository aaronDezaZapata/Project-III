using System;
using UnityEngine;

public class GrappleEntryController : MonoBehaviour
{
    private GrapplePoint _grapplePoint;

    private void Awake()
    {
        _grapplePoint = GetComponentInParent<GrapplePoint>();
    }

    private void OnTriggerEnter(Collider other)
    {
        _grapplePoint.InitializeGrapple();
    }

    private void OnTriggerExit(Collider other)
    {
        _grapplePoint.DeactivateGrapple();
    }
}
