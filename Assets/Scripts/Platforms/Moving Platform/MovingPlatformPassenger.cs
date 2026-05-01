using UnityEngine;

public class MovingPlatformPassenger : MonoBehaviour
{
    [SerializeField] private Transform platformRoot;

    private Transform originalParent;
    private Vector3 originalScale;

    private void Awake()
    {
        if (platformRoot == null)
        {
            platformRoot = transform.root;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        originalParent = other.transform.parent;
        originalScale = other.transform.localScale;

        other.transform.SetParent(platformRoot, true);
        other.transform.localScale = originalScale;

        Debug.Log("Player subido a plataforma");
    }

    private void OnTriggerExit(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        other.transform.SetParent(originalParent, true);
        other.transform.localScale = originalScale;

        Debug.Log("Player salió de plataforma");
    }
}