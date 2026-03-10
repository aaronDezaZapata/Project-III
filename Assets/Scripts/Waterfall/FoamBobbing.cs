using UnityEngine;

public class FoamBobbing : MonoBehaviour
{
    [Header("Horizontal Movement")]
    public float horizontalAmplitude = 0.15f;
    public float horizontalSpeed = 1.2f;

    [Header("Vertical Movement")]
    public float verticalAmplitude = 0.08f;
    public float verticalSpeed = 1.8f;

    [Header("Scale")]
    public float scaleAmplitude = 0.05f;
    public float scaleSpeed = 1.4f;

    [Header("Desfase")]
    public float phaseOffset = 0f;

    private Vector3 startLocalPos;
    private Vector3 startLocalScale;

    private void Start()
    {
        startLocalPos = transform.localPosition;
        startLocalScale = transform.localScale;
    }

    private void Update()
    {
        float t = Time.time + phaseOffset;

        float x = Mathf.Sin(t * horizontalSpeed) * horizontalAmplitude;
        float y = Mathf.Sin(t * verticalSpeed) * verticalAmplitude;
        float s = 1f + Mathf.Sin(t * scaleSpeed) * scaleAmplitude;

        transform.localPosition = startLocalPos + new Vector3(x, y, 0f);
        transform.localScale = new Vector3(
            startLocalScale.x * s,
            startLocalScale.y * s,
            startLocalScale.z
        );
    }
}