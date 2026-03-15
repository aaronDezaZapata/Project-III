using UnityEngine;
using UnityEngine.Rendering;

public class BarrilMovement : MonoBehaviour
{
    [Header("Movimiento vertical")]
    public float floatSpeed = 1f;
    public float floatHeight = 0.2f;
    public float driftAmount = 0.1f;
    public float driftSpeed = 0.5f;

    [Header("Balanceo")]
    public float tiltSpeed = 1.2f;
    public float tiltAmountX = 5f;
    public float tiltAmountZ = 5f;

    private Vector3 startPos;
    private Quaternion startRot;
    private float randomOffset;

    private void Start()
    {
        startPos = transform.position;
        startRot = transform.rotation;
        randomOffset = Random.Range(0f,100f);
    }

    private void Update()
    {
        float t = Time.time + randomOffset;

        float xOffset = Mathf.Sin(t * driftSpeed) * driftAmount;
        float yOffset = Mathf.Sin(t * floatSpeed) * floatHeight;
        float zOffset = Mathf.Sin(t * driftSpeed * 0.7f) * driftAmount;
        
        transform.position = new Vector3(
            startPos.x + xOffset, 
            startPos.y + yOffset, 
            startPos.z + zOffset
        );

        float rotX = Mathf.Sin(Time.time * tiltSpeed) * tiltAmountX;
        float rotZ = Mathf.Cos(Time.time * tiltSpeed * 0.8f) * tiltAmountZ;

        Quaternion extraRotation = startRot * Quaternion.Euler(rotX, 0f, rotZ);
    }
}
