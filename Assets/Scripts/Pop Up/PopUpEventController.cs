using System;
using UnityEngine;

public class PopUpEventController : MonoBehaviour
{
    public GameObject popUpToActivate;
    public GameObject eventVisuals;

    // Status Event
    [SerializeField] private bool canBeTriggered;
    
    // Event Settings
    [SerializeField] private bool eventDone;
    [SerializeField] private float actionForce;
    private float _actionLimit = 1f;
    [SerializeField] private float _currentActionAmount;
    [SerializeField] private PlayerStateMachine _player;
    

    private void OnEnable()
    {
        InputHandler.InteractionEvent += TriggerPopUp;
    }

    private void OnDisable()
    {
        InputHandler.InteractionEvent -= TriggerPopUp;
    }

    private void Update()
    {
        if (!canBeTriggered) return;

        if (_currentActionAmount <= 0f)
            _currentActionAmount = 0f;
        else
            _currentActionAmount -= Time.fixedDeltaTime;
        
        if (_currentActionAmount >= _actionLimit)
        {
            EventCompleted();
        }
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
    
    public void TriggerPopUp()
    {
        if (!canBeTriggered || _player == null) return;

        if (!_player.isOnEvent)
            _player.isOnEvent = true;
        else
            _currentActionAmount += actionForce;
        
        
    }
    
    public void EventCompleted()
    {
        eventDone = true;
        _player.isOnEvent = false;
        _player = null;
        popUpToActivate.SetActive(true);
        
        eventVisuals.SetActive(false);
        gameObject.SetActive(false);
    }
}
