using UnityEngine;

public class PortalController : MonoBehaviour
{
    [SerializeField] private GameObject portalVisual;
    [SerializeField] private Collider portalTrigger;
    [SerializeField] private ParticleSystem openParticles;
    [SerializeField] private Animator animator;

    private void Start()
    {
        if (portalVisual != null)
            portalVisual.SetActive(false);

        if (portalTrigger != null)
            portalTrigger.enabled = false;
    }

    public void OpenPortal()
    {
        if (portalVisual != null)
            portalVisual.SetActive(true);

        if (portalTrigger != null)
            portalTrigger.enabled = true;

        if (openParticles != null)
            openParticles.Play();

        if (animator != null)
            animator.SetTrigger("Open");
    }
}