using System;
using UnityEngine;



public class RotatingPlatformController : MonoBehaviour
{
    public enum RotationAxis
    {
        X, Y, Z
    }
    public bool positiveRotation;
    public RotationAxis axis;
    
    public float speed = 2f;
    public GameObject platform;

    private void Update()
    {
        switch (axis)
        {
            case RotationAxis.X:
                platform.transform.Rotate(Vector3.right * speed * Time.deltaTime);
                break;
            case RotationAxis.Y:
                platform.transform.Rotate(Vector3.up * speed * Time.deltaTime);
                break;
            case RotationAxis.Z:
                platform.transform.Rotate(Vector3.forward * speed * Time.deltaTime);
                break;
        }
    }
}
