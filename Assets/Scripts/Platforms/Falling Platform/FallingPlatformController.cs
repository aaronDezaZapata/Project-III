using UnityEngine;

public class FallingPlatformController : MonoBehaviour
{
    [Header("Timing Settings")]
    [Tooltip("Tiempo en segundos antes de que la plataforma caiga")]
    public float timeBeforeFalling = 1.0f;
    
    [Tooltip("Tiempo en segundos antes de que la plataforma vuelva a su posición")]
    public float timeBeforeRespawn = 3.0f;
    
    [Header("Movement Settings")]
    [Tooltip("Velocidad a la que la plataforma cae y sube")]
    public float movementSpeed = 2.0f;
    
    [Header("Debug")]
    [SerializeField] private float currentTimer = 0f;
    [SerializeField] private bool isCountdownActive = false;
    [SerializeField] private Vector3 originalPosition;
    [SerializeField] private PlatformState currentState = PlatformState.Idle;
    
    private enum PlatformState
    {
        Idle,
        Countdown,
        Falling,
        WaitingToRespawn,
        Rising
    }
    
    private Vector3 targetFallPosition;
    private float respawnTimer = 0f;
    
    private void Start()
    {
        // Guardar la posición original de la plataforma
        originalPosition = transform.position;
        targetFallPosition = originalPosition + new Vector3(0, -3f, 0);
    }
    
    private void Update()
    {
        // Los timers se actualizan en Update porque Time.deltaTime respeta Time.timeScale
        // Esto permite que el sistema de pausa funcione correctamente
        switch (currentState)
        {
            case PlatformState.Countdown:
                UpdateCountdown();
                break;
                
            case PlatformState.WaitingToRespawn:
                UpdateWaitingToRespawn();
                break;
        }
    }
    
    private void FixedUpdate()
    {
        // El movimiento de la plataforma se hace en FixedUpdate para mantener
        // consistencia en diferentes framerates y evitar movimientos irregulares
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
        // Detecta cuando el jugador salta sobre la plataforma
        if (other.CompareTag("Player") && currentState == PlatformState.Idle)
        {
            StartCountdown();
        }
    }
    
    private void StartCountdown()
    {
        currentState = PlatformState.Countdown;
        currentTimer = timeBeforeFalling;
        isCountdownActive = true;
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
        // Usar Time.fixedDeltaTime para movimiento consistente en FixedUpdate
        transform.position = Vector3.MoveTowards(
            transform.position,
            targetFallPosition,
            movementSpeed * Time.fixedDeltaTime
        );
        
        // Verificar si llegó a la posición objetivo
        if (Vector3.Distance(transform.position, targetFallPosition) < 0.01f)
        {
            transform.position = targetFallPosition;
            // Iniciar el temporizador de respawn
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
        // Usar Time.fixedDeltaTime para movimiento consistente en FixedUpdate
        transform.position = Vector3.MoveTowards(
            transform.position,
            originalPosition,
            movementSpeed * Time.fixedDeltaTime
        );
        
        // Verificar si llegó a la posición original
        if (Vector3.Distance(transform.position, originalPosition) < 0.01f)
        {
            transform.position = originalPosition;
            currentState = PlatformState.Idle;
            currentTimer = 0f;
        }
    }
    
    // Método para resetear la plataforma manualmente si es necesario
    public void ResetPlatform()
    {
        transform.position = originalPosition;
        currentState = PlatformState.Idle;
        currentTimer = 0f;
        respawnTimer = 0f;
        isCountdownActive = false;
    }
}
