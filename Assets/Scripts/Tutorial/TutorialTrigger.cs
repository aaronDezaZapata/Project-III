using UnityEngine;

public class TutorialTrigger : MonoBehaviour
{
    [Header("Tutorial Settings")]
    [TextArea(3, 10)]
    [SerializeField] private string tutorialMessage;

    [Header("Detection Settings")]
    [SerializeField] private string playerTag = "Player";

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(playerTag))
        {
            TutorialUIManager.Instance.ShowTutorial(tutorialMessage);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag(playerTag))
        {
            TutorialUIManager.Instance.HideTutorial();
        }
    }
}
