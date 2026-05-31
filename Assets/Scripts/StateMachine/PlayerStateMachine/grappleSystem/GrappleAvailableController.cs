using System;
using UnityEngine;

public class GrappleAvailableController : MonoBehaviour
{
    private GrapplePoint _grapplePoint;
    
    private void Awake()
    {
        _grapplePoint = GetComponentInParent<GrapplePoint>();
    }

    private void OnTriggerEnter(Collider other)
    {
        _grapplePoint.OnGripEnter();
    }

    private void OnTriggerExit(Collider other)
    {
        _grapplePoint.OnGripExit();
    }
}
