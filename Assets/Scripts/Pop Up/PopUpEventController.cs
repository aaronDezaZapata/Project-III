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
    private float actionLimit = 1f;
    private float currentActionAmount;
    

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
        
        currentActionAmount -= Time.deltaTime;
        if (currentActionAmount >= actionLimit)
        {
            EventCompleted();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        canBeTriggered = true;
    }
    
    private void OnTriggerExit(Collider other)
    {
        canBeTriggered = false;
    }
    
    public void TriggerPopUp()
    {
        if (!canBeTriggered) return;
        currentActionAmount += actionForce;
    }
    
    public void EventCompleted()
    {
        eventDone = true;
        popUpToActivate.SetActive(true);
        
        eventVisuals.SetActive(false);
        gameObject.SetActive(false);
    }
}
