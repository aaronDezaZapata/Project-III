using Unity.Cinemachine;
using UnityEngine;

public class PopUpEventController : MonoBehaviour
{
    [Header("Pop Up Event Settings")]
    [SerializeField] private GameObject _movingPlatform;
    [SerializeField] private GameObject _targetStateObject;
    [SerializeField] private GameObject _eventVisuals;
    [SerializeField] private CinemachineCamera _eventCamera;

    [Header("Player Movement Settings")]
    [SerializeField] private float _maxDistance = 5f;

    [Header("Debug")]
    [SerializeField] private bool _canBeTriggered;
    [SerializeField] private bool _eventActive;
    [SerializeField] private bool _eventDone;
    [SerializeField] private float _currentDistance;
    [SerializeField] private PlayerStateMachine _player;

    private Vector3 _platformStartPos;
    private Quaternion _platformStartRot;
    private Vector3 _platformStartScale;
    private Vector3 _targetPos;
    private Quaternion _targetRot;
    private Vector3 _targetScale;
    private Vector3 _playerStartPos;
    private Vector3 _forwardDirection;

    private void OnEnable()
    {
        InputHandler.InteractionEvent += HandleInteraction;
    }

    private void OnDisable()
    {
        InputHandler.InteractionEvent -= HandleInteraction;
    }

    private void Start()
    {
        if (_targetStateObject != null)
        {
            _targetPos   = _targetStateObject.transform.position;
            _targetRot   = _targetStateObject.transform.rotation;
            _targetScale = _targetStateObject.transform.localScale;
        }

        if (_movingPlatform != null)
        {
            _platformStartPos   = _movingPlatform.transform.position;
            _platformStartRot   = _movingPlatform.transform.rotation;
            _platformStartScale = _movingPlatform.transform.localScale;
        }

        _forwardDirection = transform.forward;
        _forwardDirection.y = 0f;
        _forwardDirection.Normalize();
    }

    private void Update()
    {
        if (!_eventActive) return;

        CalculateDistance();
        UpdatePlatform();

        if (_currentDistance >= _maxDistance)
            EventCompleted();
    }

    private void CalculateDistance()
    {
        Vector3 toPlayer     = _player.transform.position - _playerStartPos;
        float signedDistance = Vector3.Dot(toPlayer, _forwardDirection);

        _currentDistance = signedDistance < 0 ? Mathf.Abs(signedDistance) : 0f;
    }

    private void UpdatePlatform()
    {
        if (_movingPlatform == null || _targetStateObject == null) return;

        float progress = Mathf.Clamp01(_currentDistance / _maxDistance);

        _movingPlatform.transform.position   = Vector3.Lerp(_platformStartPos, _targetPos, progress);
        _movingPlatform.transform.rotation   = Quaternion.Slerp(_platformStartRot, _targetRot, progress);
        _movingPlatform.transform.localScale = Vector3.Lerp(_platformStartScale, _targetScale, progress);
    }

    private void SetPlayerEventState(bool active)
    {
        if (_player == null) return;

        _player.isOnEvent                  = active;
        _player.isRestrictedToForwardBackward = active;
        _player.eventForwardDirection      = active ? _forwardDirection : Vector3.zero;
    }

    private void HandleInteraction()
    {
        if (_eventDone || _player == null) return;

        if (!_player.isOnEvent && _canBeTriggered)
            StartEvent();
        else if (_player.isOnEvent && _eventActive)
            CancelEvent();
    }

    private void StartEvent()
    {
        _playerStartPos   = _player.transform.position;
        _currentDistance  = 0f;
        _eventActive      = true;

        _platformStartPos   = _movingPlatform.transform.position;
        _platformStartRot   = _movingPlatform.transform.rotation;
        _platformStartScale = _movingPlatform.transform.localScale;

        SetPlayerEventState(true);

        if (_eventCamera != null) _eventCamera.Priority = 10;
        if (_eventVisuals != null) _eventVisuals.SetActive(true);
    }

    private void CancelEvent()
    {
        _eventActive = false;

        if (_movingPlatform != null)
        {
            _movingPlatform.transform.position   = _platformStartPos;
            _movingPlatform.transform.rotation   = _platformStartRot;
            _movingPlatform.transform.localScale = _platformStartScale;
        }

        SetPlayerEventState(false);

        if (_eventCamera != null) _eventCamera.Priority = -1;
        if (_eventVisuals != null) _eventVisuals.SetActive(false);
    }

    private void OnTriggerEnter(Collider other)
    {
        _player = other.GetComponentInChildren<PlayerStateMachine>();
        if (_player != null)
            _canBeTriggered = true;
    }

    private void OnTriggerExit(Collider other)
    {
        if (_player == null) return;
        _canBeTriggered = false;
    }

    private void EventCompleted()
    {
        _eventDone   = true;
        _eventActive = false;

        if (_movingPlatform != null)
        {
            _movingPlatform.transform.position   = _targetPos;
            _movingPlatform.transform.rotation   = _targetRot;
            _movingPlatform.transform.localScale = _targetScale;
        }

        SetPlayerEventState(false);

        if (_eventCamera != null) _eventCamera.Priority = -1;
        if (_eventVisuals != null) _eventVisuals.SetActive(false);
    }
}
