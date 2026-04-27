using System.Collections;
using UnityEngine;

/// <summary>
/// Plataforma móvil controlada por una palanca.
/// Se suscribe al Action<string> del GameManager y solo reacciona
/// cuando el leverID recibido coincide con su propio leverID.
/// </summary>
public class MovingPlatform : MonoBehaviour
{
    [Header("Identificador de palanca")]
    [Tooltip("Ha de coincidir EXACTAMENTE con el leverID de la palanca que la controla.")]
    public string leverID = "lever_01";

    [Tooltip("Si true, la plataforma comenzará a moverse sola al inicio, sin necesitar palanca.")]
    public bool autoStart = false;

    [Header("Puntos de movimiento")]
    [Tooltip("Desplazamiento en mundo desde la posición inicial hasta el punto B.")]
    public Vector3 pointBOffset = new Vector3(5f, 0f, 0f);

    [Header("Configuración de movimiento")]
    [Tooltip("Velocidad en unidades/segundo.")]
    public float speed = 3f;

    [Tooltip("Curva de ease (X = tiempo normalizado, Y = progreso). Editable en Inspector.")]
    public AnimationCurve easeCurve = AnimationCurve.EaseInOut(0f, 0f, 1f, 1f);

    [Header("Retorno a posición inicial")]
    [Tooltip("Si true, vuelve sola al punto A tras llegar a B.")]
    public bool returnToStart = false;

    [Tooltip("Segundos de espera en B antes de volver.")]
    public float waitBeforeReturn = 1.5f;

    [Header("Loop")]
    [Tooltip("Bucle infinito A→B→A. Ignora returnToStart.")]
    public bool loop = false;

    
    private Vector3 _pointA;
    private Vector3 _pointB;
    private Coroutine _activeCoroutine;
    private bool _activated = false;   

    
    private void Start()
    {
        SubscribeToGameManager();
        _pointA = transform.position;
        _pointB = _pointA + pointBOffset;

        if (autoStart)
        {
            _activated = true;
            if (loop) StartLoop();
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
        if (GameManager.Instance == null)
        {
            Debug.LogWarning($"[MovingPlatform] '{name}': GameManager no encontrado al suscribirse.");
            return;
        }
        // Nos desuscribimos primero para evitar doble suscripción.
        GameManager.Instance.OnLeverActivated -= OnLeverActivated;
        GameManager.Instance.OnLeverActivated += OnLeverActivated;
    }

   
    private void OnLeverActivated(string id)
    {
        if (id != leverID) return;          

        if (_activated && !loop) return;    

        _activated = true;

        if (loop) StartLoop();
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
        float duration = distance / Mathf.Max(speed, 0.001f);
        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / duration);
            float curvedT = easeCurve.Evaluate(t);
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
            yield return new WaitForSeconds(waitBeforeReturn);
            yield return MoveRoutine(_pointB, _pointA, null);
            yield return new WaitForSeconds(waitBeforeReturn);
        }
    }

    private void OnArrivedAtB()
    {
        if (returnToStart)
            StartCoroutine(WaitAndReturn());
    }

    private void OnArrivedAtA() { /* queda en A */ }

    private IEnumerator WaitAndReturn()
    {
        yield return new WaitForSeconds(waitBeforeReturn);
        LaunchMove(_pointB, _pointA, OnArrivedAtA);
    }

    // ── Gizmos ──────────────────────────────────────────────────────────────
#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Vector3 worldA = transform.position;
        Vector3 worldB = Application.isPlaying ? _pointB : transform.position + pointBOffset;

        Gizmos.color = Color.green;
        Gizmos.DrawSphere(worldA, 0.18f);
        UnityEditor.Handles.Label(worldA + Vector3.up * 0.4f, $"A [{leverID}]");

        Gizmos.color = Color.red;
        Gizmos.DrawSphere(worldB, 0.18f);
        UnityEditor.Handles.Label(worldB + Vector3.up * 0.4f, "B");

        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(worldA, worldB);
    }
#endif
}