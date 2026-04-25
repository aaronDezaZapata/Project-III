using UnityEngine;
using TMPro;

public class TutorialUIManager : MonoBehaviour
{
    public static TutorialUIManager Instance { get; private set; }

    [Header("UI References")]
    [SerializeField] private RectTransform tutorialBox;
    [SerializeField] private TextMeshProUGUI tutorialText;

    [Header("Settings")]
    [SerializeField] private Vector2 hiddenPosition;
    [SerializeField] private Vector2 visiblePosition;
    [SerializeField] private float animationSpeed = 10f;

    private Vector2 targetPosition;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
            return;
        }

       
        if (tutorialBox != null)
        {
            tutorialBox.anchoredPosition = hiddenPosition;
            targetPosition = hiddenPosition;
        }
    }

    private void Update()
    {
        if (tutorialBox == null) return;

        
        tutorialBox.anchoredPosition = Vector2.Lerp(
            tutorialBox.anchoredPosition, 
            targetPosition, 
            Time.deltaTime * animationSpeed
        );
    }

    public void ShowTutorial(string text)
    {
        if (tutorialText != null)
        {
            tutorialText.text = text;
        }
        targetPosition = visiblePosition;
    }

    public void HideTutorial()
    {
        targetPosition = hiddenPosition;
    }
}
