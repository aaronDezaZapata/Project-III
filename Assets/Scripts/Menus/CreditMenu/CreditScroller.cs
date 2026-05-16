using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

public class CreditScroller : MonoBehaviour
{
    [SerializeField] private float _scrollSpeed = 50f;
    [SerializeField] private RectTransform _scrollContent;
    [SerializeField] private RectTransform _panel;
    [SerializeField] private float _endPositionY = 373f;

    private float _startPositionY;
    private bool _isScrolling;

    private IEnumerator Start()
    {
        yield return null;

        _startPositionY = _scrollContent.anchoredPosition.y;
        StartCredits();
    }

    public void StartCredits() => _isScrolling = true;

    private void Update()
    {
        if (!_isScrolling) return;

        _scrollContent.anchoredPosition += Vector2.up * _scrollSpeed * Time.deltaTime;

        if (_scrollContent.anchoredPosition.y >= _endPositionY)
        {
            _scrollContent.anchoredPosition = new Vector2(_scrollContent.anchoredPosition.x, _endPositionY);
            _isScrolling = false;
            OnCreditsFinished();
        }
    }

    private void OnCreditsFinished()
    {
        SceneManager.LoadScene("1 - MainMenu");
    }

    public void ResetCredits()
    {
        _isScrolling = false;
        _scrollContent.anchoredPosition = new Vector2(_scrollContent.anchoredPosition.x, _startPositionY);
    }
}
