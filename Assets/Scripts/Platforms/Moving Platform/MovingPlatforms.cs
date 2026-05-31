using System.Collections;
using UnityEngine;

public class MovingPlatform : MonoBehaviour
{
    [Header("Lever ID")]
    [Tooltip("Must match EXACTLY the leverID of the controlling lever.")]
    [SerializeField] private string _leverId = "lever_01";

    [Tooltip("If true, the platform starts moving on its own at startup, without needing a lever.")]
    [SerializeField] private bool _autoStart;

    [Header("Movement Points")]
    [Tooltip("World-space displacement from the initial position to point B.")]
    [SerializeField] private Vector3 _pointBOffset = new Vector3(5f, 0f, 0f);

    [Header("Movement Config")]
    [Tooltip("Speed in units/second.")]
    [SerializeField] private float _speed = 3f;

    [Tooltip("Ease curve (X = normalized time, Y = progress). Editable in Inspector.")]
    [SerializeField] private AnimationCurve _easeCurve = AnimationCurve.EaseInOut(0f, 0f, 1f, 1f);

    [Header("Return to Start")]
    [Tooltip("If true, returns to point A after reaching B.")]
    [SerializeField] private bool _returnToStart;

    [Tooltip("Seconds to wait at B before returning.")]
    [SerializeField] private float _waitBeforeReturn = 1.5f;

    [Header("Loop")]
    [Tooltip("Infinite loop A->B->A. Overrides returnToStart.")]
    [SerializeField] private bool _loop;

    private Vector3 _pointA;
    private Vector3 _pointB;
    private Coroutine _activeCoroutine;
    private bool _activated;

    private void Start()
    {
        SubscribeToGameManager();
        _pointA = transform.position;
        _pointB = _pointA + _pointBOffset;

        if (_autoStart)
        {
            _activated = true;
            if (_loop) StartLoop();
            else MoveToB();
        }
    }

    private void OnDisable()
    {
        if (GameManager.Instance != null)
            GameManager.Instance.OnLeverActivated -= OnLeverActivated;
    }

    private void SubscribeToGameManager()
    {
        if (GameManager.Instance == null) return;

        GameManager.Instance.OnLeverActivated -= OnLeverActivated;
        GameManager.Instance.OnLeverActivated += OnLeverActivated;
    }

    private void OnLeverActivated(string id)
    {
        if (id != _leverId) return;
        if (_activated && !_loop) return;

        _activated = true;

        if (_loop) StartLoop();
        else MoveToB();
    }

    public void MoveToB() => LaunchMove(_pointA, _pointB, OnArrivedAtB);
    public void MoveToA() => LaunchMove(_pointB, _pointA, OnArrivedAtA);

    public void StopMovement()
    {
        if (_activeCoroutine != null)
        {
            StopCoroutine(_activeCoroutine);
            _activeCoroutine = null;
        }
    }

    public void SnapToStart()
    {
        StopMovement();
        transform.position = _pointA;
        _activated = false;
    }

    private void LaunchMove(Vector3 from, Vector3 to, System.Action onComplete)
    {
        StopMovement();
        _activeCoroutine = StartCoroutine(MoveRoutine(from, to, onComplete));
    }

    private IEnumerator MoveRoutine(Vector3 from, Vector3 to, System.Action onComplete)
    {
        float distance = Vector3.Distance(from, to);
        float duration = distance / Mathf.Max(_speed, 0.001f);
        float elapsed  = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t       = Mathf.Clamp01(elapsed / duration);
            float curvedT = _easeCurve.Evaluate(t);
            transform.position = Vector3.LerpUnclamped(from, to, curvedT);
            yield return null;
        }

        transform.position = to;
        _activeCoroutine = null;
        onComplete?.Invoke();
    }

    private void StartLoop()
    {
        StopMovement();
        _activeCoroutine = StartCoroutine(LoopRoutine());
    }

    private IEnumerator LoopRoutine()
    {
        while (true)
        {
            yield return MoveRoutine(_pointA, _pointB, null);
            yield return new WaitForSeconds(_waitBeforeReturn);
            yield return MoveRoutine(_pointB, _pointA, null);
            yield return new WaitForSeconds(_waitBeforeReturn);
        }
    }

    private void OnArrivedAtB()
    {
        if (_returnToStart)
            StartCoroutine(WaitAndReturn());
    }

    private void OnArrivedAtA() { }

    private IEnumerator WaitAndReturn()
    {
        yield return new WaitForSeconds(_waitBeforeReturn);
        LaunchMove(_pointB, _pointA, OnArrivedAtA);
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Vector3 worldA = transform.position;
        Vector3 worldB = Application.isPlaying ? _pointB : transform.position + _pointBOffset;

        Gizmos.color = Color.green;
        Gizmos.DrawSphere(worldA, 0.18f);
        UnityEditor.Handles.Label(worldA + Vector3.up * 0.4f, $"A [{_leverId}]");

        Gizmos.color = Color.red;
        Gizmos.DrawSphere(worldB, 0.18f);
        UnityEditor.Handles.Label(worldB + Vector3.up * 0.4f, "B");

        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(worldA, worldB);
    }
#endif
}
