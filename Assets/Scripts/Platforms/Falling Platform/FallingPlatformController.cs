using UnityEngine;

public enum PlatformState
{
    Idle,
    Countdown,
    Falling,
    WaitingToRespawn,
    Rising
}

public class FallingPlatformController : MonoBehaviour
{
    [Header("Platform Settings")]
    [Tooltip("If true, platform falls on touch")]
    public bool fallsOnStay;
    [Tooltip("Time to wait before platform falls")]
    public float timeBeforeFalling = 1.0f;
    [Tooltip("Time before platform respawns")]
    public float timeBeforeRespawn = 3.0f;
    public float movementSpeed = 2.0f;

    public PlatformState CurrentState => _currentState;

    [Header("Debug")]
    [SerializeField] private float _currentTimer;
    [SerializeField] private bool _isCountdownActive;
    [SerializeField] private bool _isPlayerOnPlatform;
    [SerializeField] private Vector3 _originalPosition;
    [SerializeField] private PlatformState _currentState = PlatformState.Idle;

    private Vector3 _targetFallPosition;
    private float _respawnTimer;

    private void Start()
    {
        _originalPosition = transform.position;
        _targetFallPosition = _originalPosition + new Vector3(0, -3f, 0);
    }

    private void Update()
    {
        switch (_currentState)
        {
            case PlatformState.Countdown:
                UpdateCountdown();
                break;
            case PlatformState.WaitingToRespawn:
                UpdateWaitingToRespawn();
                break;
        }

        if (fallsOnStay && _currentState == PlatformState.Countdown && !_isPlayerOnPlatform)
            CancelCountdown();
    }

    private void FixedUpdate()
    {
        switch (_currentState)
        {
            case PlatformState.Falling:
                UpdateFalling();
                break;
            case PlatformState.Rising:
                UpdateRising();
                break;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            _isPlayerOnPlatform = true;

            if (_currentState == PlatformState.Idle)
                StartCountdown();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
            _isPlayerOnPlatform = false;
    }

    private void StartCountdown()
    {
        _currentState = PlatformState.Countdown;
        _currentTimer = timeBeforeFalling;
        _isCountdownActive = true;
    }

    private void CancelCountdown()
    {
        _currentState = PlatformState.Idle;
        _currentTimer = 0f;
        _isCountdownActive = false;
    }

    private void UpdateCountdown()
    {
        _currentTimer -= Time.deltaTime;

        if (_currentTimer <= 0f)
        {
            _currentTimer = 0f;
            _isCountdownActive = false;
            _currentState = PlatformState.Falling;
        }
    }

    private void UpdateFalling()
    {
        transform.position = Vector3.MoveTowards(
            transform.position,
            _targetFallPosition,
            movementSpeed * Time.fixedDeltaTime
        );

        if (Vector3.Distance(transform.position, _targetFallPosition) < 0.01f)
        {
            transform.position = _targetFallPosition;
            _currentState = PlatformState.WaitingToRespawn;
            _respawnTimer = timeBeforeRespawn;
        }
    }

    private void UpdateWaitingToRespawn()
    {
        _respawnTimer -= Time.deltaTime;

        if (_respawnTimer <= 0f)
        {
            _respawnTimer = 0f;
            _currentState = PlatformState.Rising;
        }
    }

    private void UpdateRising()
    {
        transform.position = Vector3.MoveTowards(
            transform.position,
            _originalPosition,
            movementSpeed * Time.fixedDeltaTime
        );

        if (Vector3.Distance(transform.position, _originalPosition) < 0.01f)
        {
            transform.position = _originalPosition;
            _currentState = PlatformState.Idle;
            _currentTimer = 0f;
        }
    }

    public void ResetPlatform()
    {
        transform.position = _originalPosition;
        _currentState = PlatformState.Idle;
        _currentTimer = 0f;
        _respawnTimer = 0f;
        _isCountdownActive = false;
        _isPlayerOnPlatform = false;
    }
}
