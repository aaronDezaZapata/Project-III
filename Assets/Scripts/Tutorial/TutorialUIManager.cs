using UnityEngine;
using TMPro;

public class TutorialUIManager : MonoBehaviour
{
    public static TutorialUIManager Instance { get; private set; }

    [Header("UI References")]
    [SerializeField] private RectTransform _tutorialBox;
    [SerializeField] private TextMeshProUGUI _tutorialText;

    [Header("Settings")]
    [SerializeField] private Vector2 _hiddenPosition;
    [SerializeField] private Vector2 _visiblePosition;
    [SerializeField] private float _animationSpeed = 10f;

    private Vector2 _targetPosition;

    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
        {
            Destroy(gameObject);
            return;
        }

        if (_tutorialBox != null)
        {
            _tutorialBox.anchoredPosition = _hiddenPosition;
            _targetPosition = _hiddenPosition;
        }
    }

    private void Update()
    {
        if (_tutorialBox == null) return;

        _tutorialBox.anchoredPosition = Vector2.Lerp(
            _tutorialBox.anchoredPosition,
            _targetPosition,
            Time.deltaTime * _animationSpeed
        );
    }

    public void ShowTutorial(string text)
    {
        if (_tutorialText != null)
            _tutorialText.text = text;

        _targetPosition = _visiblePosition;
    }

    public void HideTutorial()
    {
        _targetPosition = _hiddenPosition;
    }
}
