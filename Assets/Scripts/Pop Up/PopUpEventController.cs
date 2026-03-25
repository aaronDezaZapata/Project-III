using System;
using Unity.Cinemachine;
using UnityEngine;

public class PopUpEventController : MonoBehaviour
{
    [Header("Pop Up Event Settings")]
    public GameObject movingPlatform;
    public GameObject platformTarget;
    public GameObject eventVisuals;
    public CinemachineCamera eventCamera;
    
    public float actionForce;
    public float decreaseSpeed;

    [Header("Debug")]
    // Status Event
    [SerializeField] private bool canBeTriggered;

    // Event Settings
    [SerializeField] private bool eventDone;
    
    [SerializeField] private float _currentActionAmount;
    [SerializeField] private PlayerStateMachine _player;

    private float _actionLimit = 1f;
    private Vector3 _platformStartPos;
    private Vector3 _platformTargetPos;

    private void OnEnable()
    {
        InputHandler.InteractionEvent += TriggerPopUp;
    }

    private void OnDisable()
    {
        InputHandler.InteractionEvent -= TriggerPopUp;
    }

    private void Start()
    {
        if (movingPlatform != null)
            _platformStartPos = movingPlatform.transform.position;
        if (platformTarget != null)
            _platformTargetPos = platformTarget.transform.position;
    }

    private void Update()
    {
        if (!canBeTriggered) return;

        if (_currentActionAmount <= 0f)
            _currentActionAmount = 0f;
        else
            _currentActionAmount -= Time.deltaTime * decreaseSpeed;

        MovePlatform();

        if (_currentActionAmount >= _actionLimit)
            EventCompleted();
    }

    private void OnTriggerEnter(Collider other)
    {
        canBeTriggered = true;
        _player = other.GetComponentInChildren<PlayerStateMachine>();
    }
    
    private void OnTriggerExit(Collider other)
    {
        canBeTriggered = false;
        _player = null;
    }
    
    private void MovePlatform()
    {
        if (movingPlatform == null) return;

        float progress = Mathf.Clamp01(_currentActionAmount / _actionLimit);
        movingPlatform.transform.position = Vector3.Lerp(_platformStartPos, _platformTargetPos, progress);
    }

    public void TriggerPopUp()
    {
        if (!canBeTriggered || _player == null) return;

        if (!_player.isOnEvent)
        {
            _player.isOnEvent = true;
            eventCamera.Priority = 10;
        }
            
        else
            _currentActionAmount += actionForce;
        
        
    }
    
    public void EventCompleted()
    {
        eventDone = true;
        _player.isOnEvent = false;
        eventCamera.Priority = -1;
        _player = null;
        eventVisuals.SetActive(false);
        gameObject.SetActive(false);
    }
}
