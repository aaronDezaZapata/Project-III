using UnityEngine;

public class TransparentPlatform : MonoBehaviour
{  
    private BoxCollider solidCollider;

    [Header("Transparency")]
    [Range(0f, 1f)] public float transparentAlpha = 0.2f;
    [Range(0f, 1f)] public float opaqueAlpha = 1f;

    private Renderer rend;
    private bool isPainted = false;

    public string tagBullet = "Obstacle";

    void Start()
    {
        solidCollider = GetComponent<BoxCollider>();
        rend = GetComponent<Renderer>();

        solidCollider.enabled = false;

        SetAlpha(transparentAlpha);
    }

    
    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(tagBullet)) 
            OnInked();
    }

    public void OnInked()
    {
        if (isPainted) return;

        isPainted = true;
        solidCollider.enabled = true;


        SetAlpha(opaqueAlpha);
    }

    void SetAlpha(float alpha)
    {
        Color c = rend.material.color;
        c.a = alpha;
        rend.material.color = c;
    }
}
