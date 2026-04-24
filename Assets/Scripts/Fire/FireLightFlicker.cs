using UnityEngine;

public class FireLightFlicker : MonoBehaviour
{
    public Light fireLight;
    public float minIntensity = 2f;
    public float maxIntensity = 4f;
    public float flickerSpeed = 12f;

    private float offset;

    void Start()
    {
        if (fireLight == null)
            fireLight = GetComponent<Light>();

        offset = Random.Range(0f, 100f);
    }

    void Update()
    {
        float noise = Mathf.PerlinNoise(Time.time * flickerSpeed, offset);
        fireLight.intensity = Mathf.Lerp(minIntensity, maxIntensity, noise);
    }
}