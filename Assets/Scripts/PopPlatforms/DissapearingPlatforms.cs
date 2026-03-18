using UnityEngine;
using System.Collections;

public class DissapearingPlatforms : MonoBehaviour
{
    [Header("Timers")]
    [SerializeField] private float timeToDissapear = 2f;
    [SerializeField] private float timeToReappear = 3f;
    
    [Header("Shake Settings")]
    [SerializeField] private float shakeDuration = 0.6f;
    [SerializeField] private float shakeMagnitude = 0.05f;
    [Tooltip("If empty, it will shake this object. Better to assign a child visual object to not affect physics.")]
    [SerializeField] private Transform visualTransform;

    private Collider coll;
    private MeshRenderer meshRenderer;

    private bool isPlayerOnPlatform = false;
    private bool isDisappearing = false;

    private Vector3 originalPosition;

    void Start()
    {
        coll = GetComponent<Collider>();
        meshRenderer = GetComponentInChildren<MeshRenderer>();
        
        if (visualTransform == null)
            visualTransform = transform;
            
        originalPosition = visualTransform.localPosition;
    }

    // Usamos OnCollisionEnter por si el collider bloquea el paso
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player") && !isPlayerOnPlatform && !isDisappearing)
        {
            isPlayerOnPlatform = true;
            StartCoroutine(DisappearCoroutine());
        }
    }

    // También atrapamos OnTriggerEnter por si el jugador activa un trigger superior
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player") && !isPlayerOnPlatform && !isDisappearing)
        {
            isPlayerOnPlatform = true;
            StartCoroutine(DisappearCoroutine());
        }
    }

    private IEnumerator DisappearCoroutine()
    {
        isDisappearing = true;
        
        float timer = timeToDissapear;
        
        while (timer > 0)
        {
            timer -= Time.deltaTime;

            if (timer <= shakeDuration)
            {
                // Realizar el pequeño shake visual
                Vector3 randomPoint = originalPosition + Random.insideUnitSphere * shakeMagnitude;
                visualTransform.localPosition = randomPoint;
            }

            yield return null;
        }

        // Restaurar posición original antes de desaparecer el objeto
        visualTransform.localPosition = originalPosition;

        // Desaparecer
        SetPlatformActive(false);

        // Esperar el tiempo para reaparecer
        yield return new WaitForSeconds(timeToReappear);

        // Reaparecer
        SetPlatformActive(true);
        isPlayerOnPlatform = false;
        isDisappearing = false;
    }

    private void SetPlatformActive(bool active)
    {
        if (coll != null) coll.enabled = active;
        if (meshRenderer != null) meshRenderer.enabled = active;
    }
}
