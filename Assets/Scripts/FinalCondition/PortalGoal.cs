using UnityEngine;
using UnityEngine.SceneManagement;

public class PortalGoal : MonoBehaviour
{
    [SerializeField] private string _endingSceneName = "EndingVideo";

    private bool _isUsed;

    private void OnTriggerEnter(Collider other)
    {
        if (_isUsed || !other.CompareTag("Player")) return;

        _isUsed = true;
        SceneManager.LoadScene(_endingSceneName);
    }
}
