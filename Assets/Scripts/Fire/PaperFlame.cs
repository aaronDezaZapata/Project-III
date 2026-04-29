using UnityEngine;

public class PaperFlame : MonoBehaviour
{
    public float scaleSpeed = 8f;
    public float scaleAmount = 0.15f;
    public float moveAmount = 0.08f;
    public float rotationAmount = 4f;

    private Vector3 startScale;
    private Vector3 startPos;
    private Quaternion startRot;
    private float offset;

    void Start()
    {
        startScale = transform.localScale;
        startPos = transform.localPosition;
        startRot = transform.localRotation;
        offset = Random.Range(0f, 100f);
    }

    void Update()
    {
        float t = Time.time * scaleSpeed + offset;

        float scaleY = 1f + Mathf.Sin(t) * scaleAmount;
        float scaleX = 1f + Mathf.Sin(t * 1.3f) * scaleAmount * 0.6f;

        transform.localScale = new Vector3(
            startScale.x * scaleX,
            startScale.y * scaleY,
            startScale.z
        );

        transform.localPosition = startPos + new Vector3(
            Mathf.Sin(t * 0.8f) * moveAmount,
            Mathf.Sin(t * 1.2f) * moveAmount,
            0f
        );

        transform.localRotation = startRot * Quaternion.Euler(
            0f,
            0f,
            Mathf.Sin(t) * rotationAmount
        );
    }
}