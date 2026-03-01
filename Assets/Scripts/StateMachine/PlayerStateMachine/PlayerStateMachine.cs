using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices.WindowsRuntime;
using Unity.Cinemachine;
using Unity.VisualScripting;
using UnityEditorInternal;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerStateMachine : StateMachine
{
    #region Variables

    [field: Header("Player State")]
    [field: SerializeField] public PlayerStates playerState;

    [field: Header("Getters and Setters")]
    [field: SerializeField] public InputHandler InputReader { get; private set; }

    [field: SerializeField] public CharacterController Controller { get; private set; }
    [field: SerializeField] public ForceReceiver ForceReceiver { get; private set; }
    [field: SerializeField] public Animator Animator { get; private set; }

    [field: SerializeField] public CinemachineCamera mainCamera { get; private set; }

    [field: SerializeField] public CinemachineCamera aimCamera { get; private set; }

    [field: SerializeField] public Health Health { get; private set; }

    [field: SerializeField] public SkinnedMeshRenderer Mat_Player { get; private set; }
    
    [field: Header("Camera Sensitivity")]
    [field: Tooltip("Sensibilidad de la cámara con ratón")]
    [field: Range(0.1f, 5f)]
    [field: SerializeField] public float MouseSensitivity { get; set; } = 1f;
    
    [field: Tooltip("Sensibilidad de la cámara con mando/gamepad")]
    [field: Range(0.1f, 5f)]
    [field: SerializeField] public float GamepadSensitivity { get; set; } = 3f;


    [field: Header("Movement Variables")]
    [field: SerializeField] public float FreeLookMovementSpeed { get; private set; }
    [field: SerializeField] public float AbsorbingMovementSpeed { get; private set; }

    [field: SerializeField] public float RotationSpeed { get; private set; } = 3f;

    [field: SerializeField] public float DashDuration { get; private set; }

    [field: SerializeField] public float DashLength { get; private set; }

    [field: SerializeField] public float JumpForce { get; private set; }
    
    [field: Header("Double Jump Settings")]
    [field: Tooltip("¿El jugador tiene habilitado el doble salto?")]
    [field: SerializeField] public bool HasDoubleJump { get; private set; } = true;
    
    [field: Tooltip("Fuerza del segundo salto")]
    [field: SerializeField] public float DoubleJumpForce { get; private set; } = 15f;
    
    [field: Header("Jump Timing")]
    [field: Tooltip("Tiempo tras dejar el suelo en el que aún se puede saltar (segundos)")]
    [field: SerializeField] public float CoyoteTime { get; private set; } = 0.15f;

    [field: SerializeField] public float AccelerationTime { get; private set; } = 0.1f;

    [field: SerializeField] public float DecelerationTime { get; private set; } = 0.2f;
    
    [field: Header("Direction Change Settings")]
    [field: Tooltip("Ángulo mínimo (en grados) para detectar cambio brusco de dirección")]
    [field: SerializeField] public float DirectionChangeThreshold { get; private set; } = 90f;
    
    [field: Tooltip("Tiempo de frenado cuando se detecta cambio brusco")]
    [field: SerializeField] public float QuickStopTime { get; private set; } = 0.05f;
    
    [field: Tooltip("Velocidad mínima para considerar que el jugador se detuvo")]
    [field: SerializeField] public float QuickStopSpeedThreshold { get; private set; } = 0.3f;

    [Header("Ground Check")]
    [SerializeField] private float groundCheckDistance = 0.2f;
    [SerializeField] private float groundCheckRadius = 0.3f; 
    [SerializeField] private LayerMask groundMask;
    [SerializeField] private Transform groundCheckOrigin; 

    public bool isGrounded;


    [field: Header("Swim Mechanics")]
    [field: SerializeField] public float SwimSpeed { get; private set; } = 12f;
    [field: Tooltip("Fuerza del salto diagonal cuando se sale de una pared vertical (>60º)")]
    [field: SerializeField] public float WallJumpForce { get; private set; } = 15f;
    [field: Tooltip("Ángulo de salida de la tinta en paredes verticales (0° = vertical, 90° = horizontal)")]
    [field: Range(0f, 90f)]
    [field: SerializeField] public float WallJumpAngle { get; private set; } = 30f;
    [field: SerializeField] public GameObject InkDecalPrefab;
    [field: SerializeField] public LayerMask InkLayer;
    [field: SerializeField] public Transform GunOrigin;
    [SerializeField] public Transform reticle { get; private set; } // Quad o Canvas


    public bool IsOnInk;
    public Vector3 CurrentInkNormal = Vector3.up;

    // Flag: el WhipState no encontró objetivos en el último intento.
    // PlayerGreenState lo usa para no re-entrar hasta que el botón se suelte.
    [HideInInspector] public bool WhipFailedLastAttempt;

    [field: Header("Green Grapple Mechanics")]
    [Tooltip("¿El jugador tiene habilitado el color verde? (Dejar en true para pruebas)")]
    [field: SerializeField] public bool HasGreenAbility { get; private set; } = true;

    [Tooltip("Distancia máxima para buscar un punto de enganche")]
    [field: SerializeField] public float MaxGrappleDistance { get; private set; } = 25f;

    [Tooltip("Radio del balanceo - distancia desde el punto de enganche")]
    [field: SerializeField] public float SwingRadius { get; private set; } = 5f;

    [Tooltip("Velocidad angular mínima automática al engancharse")]
    [field: SerializeField] public float MinSwingSpeed { get; private set; } = 2f;

    [Tooltip("Cuánto puede el jugador influir en el balanceo con input")]
    [field: SerializeField] public float SwingInputForce { get; private set; } = 5f;

    [Tooltip("Fuerza del salto al desengancharse")]
    [field: SerializeField] public float GrappleJumpForce { get; private set; } = 8f;

    [Tooltip("Máscara de capas que bloquean el gancho")]
    [field: SerializeField] public LayerMask GrappleObstacleLayer { get; private set; } = ~0;

    [Header("Green Grapple Visuals")]
    [Tooltip("LineRenderer para visualizar la cuerda del gancho")]
    [field: SerializeField] public LineRenderer GrappleRope { get; private set; }

    [Tooltip("Punto desde donde sale la cuerda (mano del jugador)")]
    [field: SerializeField] public Transform GrappleRopeOrigin { get; private set; }

    [Header("Green Whip Mechanics (Enemy Attack)")]
    [Tooltip("Capa de los enemigos que pueden ser capturados")]
    [field: SerializeField] public LayerMask EnemyLayer { get; private set; }

    [Tooltip("Fuerza mínima de lanzamiento (cuando gira lento)")]
    [field: SerializeField] public float WhipThrowForceMin { get; private set; } = 15f;

    [Tooltip("Fuerza máxima de lanzamiento (cuando gira rápido)")]
    [field: SerializeField] public float WhipThrowForceMax { get; private set; } = 40f;

    [Tooltip("Distancia máxima para detectar enemigos")]
    [field: SerializeField] public float EnemyDetectionRange { get; private set; } = 15f;

    [Header("Green Whip Spin Settings")]
    [Tooltip("Velocidad inicial de giro del enemigo (grados/segundo)")]
    [field: SerializeField] public float WhipStartSpinSpeed { get; private set; } = 180f;

    [Tooltip("Aceleración del giro cuando usas WASD (grados/segundo²)")]
    [field: SerializeField] public float WhipSpinAcceleration { get; private set; } = 360f;

    [Tooltip("Velocidad máxima de giro del enemigo (grados/segundo)")]
    [field: SerializeField] public float WhipMaxSpinSpeed { get; private set; } = 720f;

    [Tooltip("Radio del círculo en el que gira el enemigo")]
    [field: SerializeField] public float WhipHoldRadius { get; private set; } = 2.5f;

    [Tooltip("Altura sobre el jugador a la que se mantiene el enemigo")]
    [field: SerializeField] public float WhipHoldHeight { get; private set; } = 2f;

    [Tooltip("Velocidad a la que el enemigo es capturado")]
    [field: SerializeField] public float WhipCaptureSpeed { get; private set; } = 20f;
    
    // TODO: Remove
    // No hay Gray
    [Header("Gray Vacuum Mechanics")]
    [Tooltip("¿El jugador tiene habilitada la habilidad gris?")]
    [field: SerializeField] public bool HasGrayAbility { get; private set; } = true;
    
    // TODO: Remove
    // No hay Gray
    [Tooltip("Capa de objetos que pueden ser absorbidos")]
    [field: SerializeField] public LayerMask AbsorbableLayer { get; private set; }

    // TODO: Remove
    // No hay Gray
    [Header("Gray Absorption Settings")]
    [Tooltip("Rango de absorción (metros)")]
    [field: SerializeField] public float GrayAbsorbRange { get; private set; } = 8f;

    [Tooltip("Ángulo del cono de absorción (grados)")]
    [Range(30f, 180f)]
    [field: SerializeField] public float GrayAbsorbAngle { get; private set; } = 90f;

    // TODO: Remove
    // No hay Gray
    [Tooltip("Velocidad de absorción base")]
    [field: SerializeField] public float GrayAbsorbSpeed { get; private set; } = 5f;

    // TODO: Remove
    // No hay Gray
    [Tooltip("Máximo de objetos absorbiendo simultáneamente")]
    [Range(1, 10)]
    [field: SerializeField] public int GrayMaxSimultaneousAbsorb { get; private set; } = 3;

    // TODO: Remove
    // No hay Gray
    [Header("Gray Holding Settings")]
    [Tooltip("Altura a la que se sostienen objetos grandes")]
    [field: SerializeField] public float GrayHoldHeight { get; private set; } = 1.5f;

    // TODO: Remove
    // No hay Gray
    [Tooltip("Distancia desde el jugador de objetos grandes")]
    [field: SerializeField] public float GrayHoldDistance { get; private set; } = 2f;

    // TODO: Remove
    // No hay Gray
    [Header("Gray Projectile Settings")]
    [Tooltip("Multiplicador de velocidad de proyectiles")]
    [field: SerializeField] public float GrayProjectileSpeedMultiplier { get; private set; } = 1.5f;

    // TODO: Remove
    // No hay Gray
    [Header("Gray Visual")]
    [Tooltip("Sistema de partículas de absorción")]
    [field: SerializeField] public ParticleSystem GrayAbsorbParticles { get; private set; }
    
    // TODO: Remove
    // No hay Gray
    [Header("Gray Absorbed Objects")]
    [Tooltip("Lista de objetos SMALL absorbidos (máximo 3)")]
    public List<AbsorbableObject> absorbedObjects = new List<AbsorbableObject>();

    public const int MaxAbsorbedSmallObjects = 3;

    [Header("References")]

    [field: SerializeField] public Transform FirePoint { get; private set; }
    [field: SerializeField] public Transform Water_JetParticle { get; private set; }
    [field: SerializeField] public Transform WaterHeiserParticle { get; private set; }
    [field: SerializeField] public Transform WaterHeiserParticleSecond { get; private set; }
    [field: SerializeField] public Rigidbody ProjectilePrefab { get; private set; }
    [field: SerializeField] public float FireCooldown { get; private set; } = 0.15f;
    [field: SerializeField] public float ProjectileFlightTime { get; private set; } = 0.6f;
    [field: SerializeField] public LayerMask PaintableLayer { get; private set; } = ~0;

    [field: Header("Shooting Config")]
    [field: SerializeField] public float AimMovementSpeed = 3f;
    [field: SerializeField] public float HorizontalSensitivity = 150f;
    [field: SerializeField] public float VerticalSensitivity = 100f;
    [field: SerializeField] public float MinVerticalAngle = -60f;
    [field: SerializeField] public float MaxVerticalAngle = 60f;

    // TODO: Remove
    // Reticula cambiada
    [field: Header("Reticle Config")]
    [field: SerializeField] public Transform ReticleTransform { get; private set; } // El objeto visual de la mira
    [field: SerializeField] public float MaxAimDistance { get; private set; } = 80f;
    [field: SerializeField] public LayerMask AimLayerMask { get; private set; } = ~0;
    [field: SerializeField] public float ReticleSurfaceOffset { get; private set; } = 0.02f;

    [field: Header("Heiser")]
    [field: SerializeField] public float HoverForce { get; private set; } = 15f;
    [field: SerializeField] public float aerialMoveSpeed { get; private set; } = 10f;
    
    public bool CanHeiser { get; set; } = true;
    
    /// <summary>
    /// Dash variables
    /// </summary>
    
    // TODO: Remove
    // Ya no hay combate
    [field: Header("Black Dash Attack (Painted Enemy)")]
    [Tooltip("¿El jugador tiene habilitado el dash attack a enemigos pintados?")]
    [field: SerializeField] public bool HasDashAttack { get; private set; } = true;

    [Tooltip("Velocidad del dash hacia el enemigo")]
    [field: SerializeField] public float DashAttackSpeed { get; private set; } = 25f;

    [Tooltip("Rango máximo para detectar enemigos pintados")]
    [field: SerializeField] public float DashAttackMaxRange { get; private set; } = 20f;

    [Tooltip("Radio de colisión para detectar impacto con enemigo")]
    [field: SerializeField] public float DashAttackCollisionRadius { get; private set; } = 1.5f;

    [Tooltip("Fuerza del impulso horizontal hacia atrás tras golpear")]
    [field: SerializeField] public float DashAttackKnockbackForce { get; private set; } = 8f;

    [Tooltip("Fuerza del impulso vertical tras golpear")]
    [field: SerializeField] public float DashAttackVerticalKnockback { get; private set; } = 5f;
    
    #endregion


    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        AddState(new PlayerFreeLookState(this));
        AddState(new PlayerSwimState(this));
        AddState(new PlayerDashAttackState(this));
        AddState(new PlayerShootingState(this));
        AddState(new PlayerBlueState(this));
        AddState(new PlayerHeiserState(this));
        AddState(new PlayerGreenState(this));
        AddState(new PlayerWhipState(this));
        AddState(new PlayerGrayState(this));
        AddState(new PlayerAbsorbState(this));

        // MUST BE PLAYERFREELOOK. CHANGES ONLY FOR TESTING
        SwitchState(typeof(PlayerFreeLookState));
    }

    public void StartCameraShake(float duration)
    {
        StartCoroutine(ShakeRoutine(duration));
    }

    public IEnumerator ShakeRoutine(float duration)
    {
        mainCamera.GetComponent<CinemachineBasicMultiChannelPerlin>().AmplitudeGain = 5f;
        mainCamera.GetComponent<CinemachineBasicMultiChannelPerlin>().FrequencyGain = 2f;
        float elapsed = 0f;
        
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;

            yield return null;
        }

        mainCamera.GetComponent<CinemachineBasicMultiChannelPerlin>().AmplitudeGain = 0f;
        mainCamera.GetComponent<CinemachineBasicMultiChannelPerlin>().FrequencyGain = 0f;
    }
    
    // TODO: Remove
    /*void HandleTakeDamage()
    {
        //SwitchState(PlayerImpactState);
    }

    void HandleDie()
    {
        // SwitchState( PlayerDeadState);
    }*/


    public void CheckForInk()
    {
        Vector3 detectionOrigin = transform.TransformPoint(Controller.center);
        
        Collider[] hitColliders = Physics.OverlapSphere(detectionOrigin, 0.7f, InkLayer);

        if (hitColliders.Length > 0)
        {
            IsOnInk = true;

            RaycastHit hit;
            
            if (Physics.Raycast(detectionOrigin, -transform.up, out hit, 1.5f, InkLayer))
            {
                CurrentInkNormal = hit.normal;
            }
            else
            {
                CurrentInkNormal = hitColliders[0].transform.forward * -1f;
            }
        }
        else
        {
            IsOnInk = false;
            CurrentInkNormal = Vector3.up;
        }
    }


    public void PaintSurface(Vector3 point, Vector3 normal)
    {
        if (InkDecalPrefab == null) return;
        
        Quaternion alignmentRotation = Quaternion.FromToRotation(Vector3.up, normal);
        Quaternion fixRotation = Quaternion.Euler(90f, 0f, 0f);
        Quaternion finalRotation = alignmentRotation * fixRotation;

        GameObject splat = Instantiate(InkDecalPrefab, point, finalRotation);
        splat.transform.position += normal * ReticleSurfaceOffset;
    }

    private void OnTriggerEnter(Collider other)
    {

        switch (other.tag)
        {
            case "CharcoAzul":
                SwitchState(typeof(PlayerBlueState));
                //Mat_Player.SetColor("_Color", Color.blue);
                if (Mat_Player != null)
                {
                    Mat_Player.material.SetColor("_SpecularColor", Color.blue);
                }
                break;

            case "CharcoNegro":
                SwitchState(typeof(PlayerFreeLookState));
                if (Mat_Player != null)
                {
                    Color blackColor = new Color(1 - 38f, 1 - 38f, 1 - 38f);
                    Mat_Player.material.SetColor("_SpecularColor", blackColor);
                }
                break;
            
            // TODO: Remove
            /*case "CharcoGris":
                SwitchState(typeof(PlayerGrayState));
                if (Mat_Player != null)
                {
                    Mat_Player.material.SetColor("_SpecularColor", Color.grey);
                }
                break;*/

            case "CharcoVerde":
                SwitchState(typeof(PlayerGreenState));
                if (Mat_Player != null)
                {
                    Mat_Player.material.SetColor("_SpecularColor", Color.green);
                }
                break;

            case "CheckPoint":
                GameManager.Instance.GetNewCheckPoint(other.transform);
                break;

            default:
                break;
        }
    }


    private void OnControllerColliderHit(ControllerColliderHit hit)
    {
        switch(hit.transform.tag)
        {
            case "Insta":
                GameManager.Instance.PlayerDeath();
                break;
                default : break;
        }
    }
    
    public void ReturnToMainState()
    {
        switch (playerState)
        {
            case PlayerStates.BLACK:
                SwitchState(typeof(PlayerFreeLookState));
                break;
            case PlayerStates.BLUE:
                SwitchState(typeof(PlayerBlueState));
                break;
            case PlayerStates.GREEN:
                SwitchState(typeof(PlayerGreenState));
                break;
            // TODO: Remove
            /*case PlayerStates.GREY:
                SwitchState(typeof(PlayerGrayState));
                break;*/
        }
    }
    
    public Vector3 CalculateMovement()
    {
        Vector3 forward = Camera.main.transform.forward;
        Vector3 right = Camera.main.transform.right;

        forward.y = 0f;
        right.y = 0f;

        forward.Normalize();
        right.Normalize();

        return forward * InputReader.MoveVector.y + right * InputReader.MoveVector.x;
    }

    public void CheckGrounded()
    {
        isGrounded = Physics.SphereCast(
            groundCheckOrigin.position,
            groundCheckRadius,
            Vector3.down,
            out RaycastHit hit,
            groundCheckDistance,
            groundMask
        );
    }


    public void FaceMovementDirection(Vector3 movement, float deltaTime)
    {
        transform.rotation = Quaternion.Lerp(
            transform.rotation,
            Quaternion.LookRotation(movement),
            deltaTime * RotationSpeed);
    }

    public void FaceMovementDirectionInstant(Vector3 movement)
    {
        // Verificamos que haya movimiento para evitar errores de LookRotation
        if (movement != Vector3.zero)
        {
            transform.rotation = Quaternion.LookRotation(movement);
        }
    }

    /*#region Gray Absorbed Objects Management

    /// <summary>
    /// Añade un objeto SMALL a la lista de absorbidos (máximo 3)
    /// </summary>
    public bool TryAddAbsorbedObject(AbsorbableObject obj)
    {
        if (obj == null) return false;
        if (absorbedObjects.Count >= MaxAbsorbedSmallObjects) return false;
        
        absorbedObjects.Add(obj);
        Debug.Log($"Objeto SMALL añadido. Total: {absorbedObjects.Count}/{MaxAbsorbedSmallObjects}");
        return true;
    }
    
    /// <summary>
    /// Verifica si hay objetos SMALL absorbidos
    /// </summary>
    public bool HasAbsorbedSmallObjects()
    {
        return absorbedObjects.Count > 0;
    }
    
    /// <summary>
    /// Obtiene el primer objeto SMALL de la lista
    /// </summary>
    public AbsorbableObject GetFirstAbsorbedObject()
    {
        if (absorbedObjects.Count == 0) return null;
        return absorbedObjects[0];
    }
    
    /// <summary>
    /// Remueve el primer objeto SMALL de la lista después de dispararlo
    /// </summary>
    public void RemoveFirstAbsorbedObject()
    {
        if (absorbedObjects.Count > 0)
        {
            absorbedObjects.RemoveAt(0);
            Debug.Log($"Objeto SMALL disparado. Restantes: {absorbedObjects.Count}/{MaxAbsorbedSmallObjects}");
        }
    }

    #endregion*/

    public float GetCurrentCameraSensitivity()
    {
        return InputReader.IsUsingGamepad ? GamepadSensitivity : MouseSensitivity;
    }

    private void OnDrawGizmosSelected()
    {
        if (groundCheckOrigin == null) return;

        Gizmos.color = Color.green;

        // Esfera en el origen
        Gizmos.DrawWireSphere(groundCheckOrigin.position, groundCheckRadius);

        // Dirección del SphereCast
        Vector3 castDirection = Vector3.down * groundCheckDistance;

        // Esfera al final del cast
        Vector3 endPosition = groundCheckOrigin.position + castDirection;
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(endPosition, groundCheckRadius);

        // Línea que conecta ambas
        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(groundCheckOrigin.position, endPosition);

        // Si está grounded en editor (opcional, solo en Play Mode)
        if (Application.isPlaying)
        {
            if (Physics.SphereCast(
                groundCheckOrigin.position,
                groundCheckRadius,
                Vector3.down,
                out RaycastHit hit,
                groundCheckDistance,
                groundMask
            ))
            {
                Gizmos.color = Color.red;
                Gizmos.DrawSphere(hit.point, 0.05f);
            }
        }
    }
}
