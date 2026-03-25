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
    
    public PlatformState CurrentState => currentState;
    
    [Header("Debug")]
    [SerializeField] private float currentTimer;
    [SerializeField] private bool isCountdownActive;
    [SerializeField] private bool isPlayerOnPlatform;
    [SerializeField] private Vector3 originalPosition;
    [SerializeField] private PlatformState currentState = PlatformState.Idle;
    
    private Vector3 targetFallPosition;
    private float respawnTimer = 0f;
    
    private void Start()
    {
        originalPosition = transform.position;
        targetFallPosition = originalPosition + new Vector3(0, -3f, 0);
    }
    
    private void Update()
    {
        switch (currentState)
        {
            case PlatformState.Countdown:
                UpdateCountdown();
                break;
                
            case PlatformState.WaitingToRespawn:
                UpdateWaitingToRespawn();
                break;
        }
        
        if (fallsOnStay && currentState == PlatformState.Countdown && !isPlayerOnPlatform)
            CancelCountdown();
    }
    
    private void FixedUpdate()
    {
        switch (currentState)
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
            isPlayerOnPlatform = true;
            
            if (!fallsOnStay && currentState == PlatformState.Idle || 
                fallsOnStay && currentState == PlatformState.Idle)
                StartCountdown();
        }
    }
    
    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            isPlayerOnPlatform = false;
        }
    }
    
    private void StartCountdown()
    {
        currentState = PlatformState.Countdown;
        currentTimer = timeBeforeFalling;
        isCountdownActive = true;
    }
    
    private void CancelCountdown()
    {
        currentState = PlatformState.Idle;
        currentTimer = 0f;
        isCountdownActive = false;
    }
    
    private void UpdateCountdown()
    {
        currentTimer -= Time.deltaTime;
        
        if (currentTimer <= 0f)
        {
            currentTimer = 0f;
            isCountdownActive = false;
            currentState = PlatformState.Falling;
        }
    }
    
    private void UpdateFalling()
    {
        transform.position = Vector3.MoveTowards(
            transform.position,
            targetFallPosition,
            movementSpeed * Time.fixedDeltaTime
        );
        

        if (Vector3.Distance(transform.position, targetFallPosition) < 0.01f)
        {
            transform.position = targetFallPosition;

            currentState = PlatformState.WaitingToRespawn;
            respawnTimer = timeBeforeRespawn;
        }
    }
    
    private void UpdateWaitingToRespawn()
    {
        respawnTimer -= Time.deltaTime;
        
        if (respawnTimer <= 0f)
        {
            respawnTimer = 0f;
            currentState = PlatformState.Rising;
        }
    }
    
    private void UpdateRising()
    {
        transform.position = Vector3.MoveTowards(
            transform.position,
            originalPosition,
            movementSpeed * Time.fixedDeltaTime
        );
        
        if (Vector3.Distance(transform.position, originalPosition) < 0.01f)
        {
            transform.position = originalPosition;
            currentState = PlatformState.Idle;
            currentTimer = 0f;
        }
    }
    
    public void ResetPlatform()
    {
        transform.position = originalPosition;
        currentState = PlatformState.Idle;
        currentTimer = 0f;
        respawnTimer = 0f;
        isCountdownActive = false;
        isPlayerOnPlatform = false;
    }
}
