using Unity.Cinemachine;
using UnityEngine;

public class PopUpEventController : MonoBehaviour
{
    [Header("Pop Up Event Settings")]
    public GameObject movingPlatform;
    public GameObject targetStateObject;
    public GameObject eventVisuals;
    public CinemachineCamera eventCamera;

    [Header("Player Movement Settings")]
    public float maxDistance = 5f;
    
    [Header("Debug")]
    [SerializeField] private bool canBeTriggered;
    [SerializeField] private bool eventActive;
    [SerializeField] private bool eventDone;
    [SerializeField] private float currentDistance;
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
        if (targetStateObject != null)
        {
            _targetPos = targetStateObject.transform.position;
            _targetRot = targetStateObject.transform.rotation;
            _targetScale = targetStateObject.transform.localScale;
        }

        if (movingPlatform != null)
        {
            _platformStartPos = movingPlatform.transform.position;
            _platformStartRot = movingPlatform.transform.rotation;
            _platformStartScale = movingPlatform.transform.localScale;
        }

        _forwardDirection = transform.forward;
        _forwardDirection.y = 0f;
        _forwardDirection.Normalize();
    }

    private void Update()
    {
        if (eventActive)
        {
            CalculateDistance();
            UpdatePlatform();
            
            if (currentDistance >= maxDistance)
            {
                EventCompleted();
            }
        }
    }

    private void CalculateDistance()
    {
        Vector3 toPlayer = _player.transform.position - _playerStartPos;
        float signedDistance = Vector3.Dot(toPlayer, _forwardDirection);
        
        if (signedDistance < 0)
            currentDistance = Mathf.Abs(signedDistance);
        else
            currentDistance = 0f;
    }

    private void UpdatePlatform()
    {
        if (movingPlatform == null || targetStateObject == null) return;

        float progress = Mathf.Clamp01(currentDistance / maxDistance);

        movingPlatform.transform.position = Vector3.Lerp(_platformStartPos, _targetPos, progress);
        movingPlatform.transform.rotation = Quaternion.Slerp(_platformStartRot, _targetRot, progress);
        movingPlatform.transform.localScale = Vector3.Lerp(_platformStartScale, _targetScale, progress);
    }

    private void UpdatePlayerEventState(bool active)
    {
        if (_player != null)
        {
            _player.isOnEvent = active;
            _player.isRestrictedToForwardBackward = active;
            _player.eventForwardDirection = active ? _forwardDirection : Vector3.zero;
        }
    }

    private void HandleInteraction()
    {
        if (eventDone) return;
        if (_player == null) return;
        
        if (_player != null && canBeTriggered && !_player.isOnEvent)
            StartEvent();
        else if (_player.isOnEvent && eventActive)
            CancelEvent();
        
    }

    private void StartEvent()
    {
        _playerStartPos = _player.transform.position;
        currentDistance = 0f;
        eventActive = true;

        _platformStartPos = movingPlatform.transform.position;
        _platformStartRot = movingPlatform.transform.rotation;
        _platformStartScale = movingPlatform.transform.localScale;

        UpdatePlayerEventState(true);

        if (eventCamera != null)
            eventCamera.Priority = 10;

        if (eventVisuals != null)
            eventVisuals.SetActive(true);
    }

    private void CancelEvent()
    {
        eventActive = false;

        if (movingPlatform != null)
        {
            movingPlatform.transform.position = _platformStartPos;
            movingPlatform.transform.rotation = _platformStartRot;
            movingPlatform.transform.localScale = _platformStartScale;
        }

        UpdatePlayerEventState(false);

        if (eventCamera != null)
            eventCamera.Priority = -1;

        if (eventVisuals != null)
            eventVisuals.SetActive(false);
    }

    private void OnTriggerEnter(Collider other)
    {
        _player = other.GetComponentInChildren<PlayerStateMachine>();
        if (_player != null)
        {
            canBeTriggered = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (_player == null) return;
        
        canBeTriggered = false;
    }

    private void EventCompleted()
    {
        eventDone = true;
        eventActive = false;

        if (movingPlatform != null)
        {
            movingPlatform.transform.position = _targetPos;
            movingPlatform.transform.rotation = _targetRot;
            movingPlatform.transform.localScale = _targetScale;
        }

        UpdatePlayerEventState(false);

        if (eventCamera != null)
            eventCamera.Priority = -1;

        if (eventVisuals != null)
            eventVisuals.SetActive(false);
    }
}