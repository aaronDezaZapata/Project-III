using UnityEngine;
using UnityEngine.SceneManagement;

public class PortalGoal : MonoBehaviour
{
    [SerializeField] private string endingSceneName = "EndingVideo";

    private bool used = false;

    private void OnTriggerEnter(Collider other)
    {
        if (used) return;
        if (!other.CompareTag("Player")) return;

        used = true;
        SceneManager.LoadScene(endingSceneName);
    }
}