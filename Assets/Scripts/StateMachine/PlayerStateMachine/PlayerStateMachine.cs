using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Cinemachine;
using UnityEngine;

public class PlayerStateMachine : StateMachine
{
    #region Variables

    private Dictionary<Color, Type> colorToStateDic;

    [field: Header("Player State")]
    [field: SerializeField] public PlayerStates playerState;
    [field: SerializeField] public bool isOnEvent;
    [field: SerializeField] public bool isRestrictedToForwardBackward;
    [field: SerializeField] public Vector3 eventForwardDirection;

    [field: Header("Getters and Setters")]
    [field: SerializeField] public InputHandler InputReader { get; private set; }

    [field: SerializeField] public CharacterController Controller { get; private set; }
    [field: SerializeField] public ForceReceiver ForceReceiver { get; private set; }
    [field: SerializeField] public Animator Animator { get; private set; }

    [field: SerializeField] public CinemachineCamera mainCamera { get; private set; }

    [field: SerializeField] public CinemachineCamera aimCamera { get; private set; }
    [field: SerializeField] public PitchCameraControl aimCameraPitchControl { get; private set; }

    [field: SerializeField] public Health Health { get; private set; }

    [field: SerializeField] public SkinnedMeshRenderer Mat_Player { get; private set; }

    [field: Header("Audio")]
    [field: SerializeField] public PlayerAudio PlayerAudio { get; private set; }

    [field: Header("Mesh Settings")]
    [field: SerializeField] public GameObject OriginalMesh { get; private set; }
    [field: SerializeField] public GameObject SharkFinMesh { get; private set; }
    
    [field: Header("Camera Sensitivity")]
    [field: Range(0.1f, 5f)]
    [field: SerializeField] public float MiceSensitivity { get; set; } = 1f;
    
    [field: Range(0.1f, 5f)]
    [field: SerializeField] public float GamepadSensitivity { get; set; } = 3f;
    
    [field: SerializeField] public bool XAxisInverted { get; set; }
    
    [field: Header("Aim Camera Sensitivity")]
    [field: Range(0.1f, 5f)]
    [field: SerializeField] public float MiceAimSensitivity { get; set; } = 1f;
    
    [field: Range(0.1f, 5f)]
    [field: SerializeField] public float GamepadAimSensitivity { get; set; } = 3f;

    [field: SerializeField] public bool AimXAxisInverted { get; set; }


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
    [Tooltip("Velocidad de deslizamiento en slopes que superan el slopeLimit")]
    [SerializeField] public float slopeSlideSpeed = 8f;

    public bool isGrounded;
    public bool isOnSteepSlope;

    [field: Header("Particles")]
    [field: SerializeField] public ParticleSystem FootstepParticles1 { get; private set; }
    [field: SerializeField] public ParticleSystem FootstepParticles2 { get; private set; }
    [field: SerializeField] public ParticleSystem LandingParticles { get; private set; }
    [field: SerializeField] public float MinFallVelocityToPlayLandingParticle { get; private set; } = 5f;

    private int _footstepIndex = 0;
    private float lastAirVerticalVelocity;
    private bool hasBeenAirborne;


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

    [NonSerialized] public PlayerStateMachine[] playerColorStates;
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

    [Header("Green Whip Mechanics (Object Attack)")]
    [Tooltip("Capa de los objetos que pueden ser capturados")]
    [field: SerializeField] public LayerMask WhipObjectLayer { get; private set; }

    [Tooltip("Fuerza mínima de lanzamiento (cuando gira lento)")]
    [field: SerializeField] public float WhipThrowForceMin { get; private set; } = 15f;

    [Tooltip("Fuerza máxima de lanzamiento (cuando gira rápido)")]
    [field: SerializeField] public float WhipThrowForceMax { get; private set; } = 40f;

    [Tooltip("Distancia máxima para detectar objetos")]
    [field: SerializeField] public float WhipObjectDetectionRange { get; private set; } = 15f;

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

    [Tooltip("Ajustes para Shadow Drop")]
    [field: SerializeField] public float MaxDistance { get; private set; } = 25f;
    [field: SerializeField] public float ScaleNear { get; private set; } = 0.6f;
    [field: SerializeField] public float ScaleFar { get; private set; } = 1.4f;
    [field: SerializeField] public float AlphaNear { get; private set; } = 0.95f;
    [field: SerializeField] public float AlphaFar { get; private set; } = 0.15f;
    [field: SerializeField] public float OffsetY { get; private set; } = 0.02f; //Para el z-fighting
    [field: SerializeField] public Transform ShadowDrop { get; private set; }
    
    public const int MaxAbsorbedSmallObjects = 3;

    [Header("References")]

    [field: SerializeField] public Transform FirePoint { get; private set; }
    [field: SerializeField] public Transform Water_JetParticle { get; private set; }
    [field: SerializeField] public Transform WaterGeyserParticle { get; private set; }
    [field: SerializeField] public Transform WaterGeyserParticleSecond { get; private set; }
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

    // GEYSER VARIABLES
    [field: Header("Geyser Settings")]
    [field: Tooltip("Fuerza de flotación vertical")]
    [field: SerializeField] public float HoverForce { get; private set; } = 15f;
    
    [field: Tooltip("Velocidad de movimiento aéreo durante Geyser")]
    [field: SerializeField] public float aerialMoveSpeed { get; private set; } = 10f;
    
    [field: Tooltip("Tiempo en segundos que debe mantenerse el salto en el aire para activar Geyser")]
    [field: SerializeField] public float GeyserActivationTime { get; private set; } = 0.5f;
    
    [field: Tooltip("Fuerza del impulso vertical inicial al entrar al estado Geyser")]
    [field: SerializeField] public float GeyserInitialBoostForce { get; private set; } = 10f;
    
    [field: Tooltip("Tiempo de cooldown después de usar Geyser antes de poder usarlo de nuevo")]
    [field: SerializeField] public float GeyserCooldownTime { get; private set; } = 1f;
    
    // Geyser cooldown variables
    [HideInInspector] public float geyserCooldownTimer = 0f;
    [HideInInspector] public bool isGeyserOnCooldown = false;
    [HideInInspector] public bool wasJumpButtonReleased = true;
    private Coroutine fillCoroutine;
    private float fillSpeed = 5f;

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

    private string currentPuddleTag = "";

    private void Awake()
    {
        if (PlayerAudio == null)
        {
            PlayerAudio = GetComponentInChildren<PlayerAudio>();
        }
        // Asigno un material sin fricción.
        CapsuleCollider extraCollider = GetComponent<CapsuleCollider>();
        if (extraCollider != null && !extraCollider.isTrigger)
        {
            PhysicsMaterial noFrictionMat = new PhysicsMaterial("NoFriction");
            noFrictionMat.dynamicFriction = 0f;
            noFrictionMat.staticFriction = 0f;
            noFrictionMat.frictionCombine = PhysicsMaterialCombine.Minimum;
            noFrictionMat.bounceCombine = PhysicsMaterialCombine.Minimum;
            extraCollider.material = noFrictionMat;
        }
    }

    private void Start()
    {
        AddState(new PlayerWhiteState(this));
        AddState(new PlayerSwimState(this));
        AddState(new PlayerShootingState(this));
        AddState(new PlayerBlueState(this));
        AddState(new PlayerGeyserState(this));
        AddState(new PlayerGreenState(this));
        AddState(new PlayerWhipState(this));
        AddState(new PlayerRedState(this));
        AddState(new PlayerFlyState(this));

        colorToStateDic = new Dictionary<Color, Type>
        {
            { Color.red, typeof(PlayerRedState) },
            { Color.green, typeof(PlayerGreenState) },
            { Color.blue, typeof(PlayerBlueState) },
            { Color.white, typeof(PlayerWhiteState) }
        };

        // MUST BE PLAYERFREELOOK. CHANGES ONLY FOR TESTING
        SwitchState(typeof(PlayerWhiteState));
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

        PlayerAudio?.PlayPaintSpread();
    }

    private void OnTriggerEnter(Collider other)
    {

        switch (other.tag)
        {
            case "CharcoAzul":
            case "CharcoNegro":
            case "CharcoRojo":
            case "CharcoVerde":
                currentPuddleTag = other.tag;
                break;

            case "CheckPoint":
                GameManager.Instance.GetNewCheckPoint(other.transform);
                AudioManager.Instance?.PlayUICheckpoint();
                break;

            default:
                break;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == currentPuddleTag)
        {
            currentPuddleTag = "";
        }
    }

    public void HandlePuddleInteraction()
    {
        switch (currentPuddleTag)
        {
            case "CharcoAzul":
                PlayerAudio?.PlayInkwell();
                StartFill(Color.blue);
                break;

            case "CharcoRojo":
                PlayerAudio?.PlayInkwell();
                StartFill(Color.red);
                break;

            case "CharcoVerde":
                PlayerAudio?.PlayInkwell();
                StartFill(Color.green);
                break;

            case "CharcoNegro":
                PlayerAudio?.PlayInkwell();
                SwitchState(typeof(PlayerWhiteState));
                break;
        }
    }

    public void ReturnToMainState()
    {
        switch (playerState)
        {
            case PlayerStates.WHITE:
                SwitchState(typeof(PlayerWhiteState));
                break;
            case PlayerStates.RED:
                SwitchState(typeof(PlayerRedState));
                break;
            case PlayerStates.BLUE:
                SwitchState(typeof(PlayerBlueState));
                break;
            case PlayerStates.GREEN:
                SwitchState(typeof(PlayerGreenState));
                break;
        }
    }

    public void ForceExitSwimState(Vector3 pushDirection, float pushForce)
    {
        if (GetCurrentState() is not PlayerSwimState)
            return;

        if (!ForceReceiver.isActiveAndEnabled)
            ForceReceiver.enabled = true;

        ReturnToMainState();

        if (pushForce > 0f)
        {
            ForceReceiver.AddForce(pushDirection.normalized * pushForce);
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
        bool wasGroundedBefore = isGrounded;

        bool hitGround = Physics.SphereCast(
            groundCheckOrigin.position,
            groundCheckRadius,
            Vector3.down,
            out RaycastHit hit,
            groundCheckDistance,
            groundMask
        );

        if (hitGround)
        {
            float angle = Vector3.Angle(Vector3.up, hit.normal);
            isGrounded = angle <= Controller.slopeLimit;
        }
        else
        {
            isGrounded = false;
        }

        // Mientras estamos en el aire, guardamos la última velocidad vertical real.
        if (!isGrounded)
        {
            hasBeenAirborne = true;

            float controllerY = Controller != null ? Controller.velocity.y : 0f;
            float forceReceiverY = ForceReceiver != null ? ForceReceiver.VerticalVelocity : 0f;

            // Nos quedamos con la más negativa, porque representa mejor una caída.
            lastAirVerticalVelocity = Mathf.Min(controllerY, forceReceiverY);
        }

        // Momento exacto de aterrizaje.
        if (!wasGroundedBefore && isGrounded && hasBeenAirborne)
        {
            float fallSpeed = Mathf.Abs(lastAirVerticalVelocity);

            if (fallSpeed >= MinFallVelocityToPlayLandingParticle)
            {
                if (LandingParticles != null)
                    LandingParticles.Play();
            }

            if (fallSpeed >= 8f)
            {
                PlayerAudio?.PlayHeavyImpact();
            }
            else if (fallSpeed >= 1.5f)
            {
                PlayerAudio?.PlayLanding();
            }

            hasBeenAirborne = false;
            lastAirVerticalVelocity = 0f;
        }

        if (isGrounded)
        {
            isGeyserOnCooldown = false;
            geyserCooldownTimer = 0f;
            isOnSteepSlope = false;
        }
    }

    public void PlayFootstepParticle()
    {
        if (!isGrounded)
            return;

        if (_footstepIndex == 0)
        {
            if (FootstepParticles1 != null) FootstepParticles1.Play();
            _footstepIndex = 1;
        }
        else
        {
            if (FootstepParticles2 != null) FootstepParticles2.Play();
            _footstepIndex = 0;
        }

        FootstepSurfaceType surfaceType = DetectFootstepSurface();
        FootstepSpeedType speedType = DetectFootstepSpeed();

        Debug.Log("FOOTSTEP: " + surfaceType + " / " + speedType);

        PlayerAudio?.PlayFootstep(surfaceType, speedType);
    }

    private FootstepSpeedType DetectFootstepSpeed()
    {
        Vector3 horizontalVelocity = new Vector3(
            Controller.velocity.x,
            0f,
            Controller.velocity.z
        );

        float speed = horizontalVelocity.magnitude;

        return speed >= 4.5f
            ? FootstepSpeedType.Run
            : FootstepSpeedType.Walk;
    }

    private FootstepSurfaceType DetectFootstepSurface()
    {
        if (groundCheckOrigin == null)
            return FootstepSurfaceType.Ink;

        bool hitGround = Physics.SphereCast(
            groundCheckOrigin.position,
            groundCheckRadius,
            Vector3.down,
            out RaycastHit hit,
            groundCheckDistance + 0.3f,
            groundMask
        );

        if (!hitGround)
            return FootstepSurfaceType.Ink;

        int layer = hit.collider.gameObject.layer;

        if (layer == LayerMask.NameToLayer("Ink"))
            return FootstepSurfaceType.Ink;

        if (layer == LayerMask.NameToLayer("Leaves"))
            return FootstepSurfaceType.Leaves;

        if (layer == LayerMask.NameToLayer("Rock"))
            return FootstepSurfaceType.Rock;

        if (layer == LayerMask.NameToLayer("Sand"))
            return FootstepSurfaceType.Sand;

        if (layer == LayerMask.NameToLayer("Wood"))
            return FootstepSurfaceType.Wood;

        return FootstepSurfaceType.Ink;
    }

    /// <summary>
    /// Aplica una fuerza de deslizamiento hacia abajo de la slope cuando
    /// el ángulo supera el slopeLimit del CharacterController.
    /// Llamar cada frame desde el Tick del estado activo.
    /// </summary>
    public void ApplySlopeSlide()
    {
        bool hitGround = Physics.SphereCast(
            groundCheckOrigin.position,
            groundCheckRadius,
            Vector3.down,
            out RaycastHit hit,
            groundCheckDistance,
            groundMask
        );

        if (!hitGround) return;

        float angle = Vector3.Angle(Vector3.up, hit.normal);
        if (angle <= Controller.slopeLimit) return;

        // Estamos en una slope demasiado empinada
        isOnSteepSlope = true;

        // Calculamos la dirección de deslizamiento: proyección horizontal de la normal invertida
        Vector3 slideDir = Vector3.ProjectOnPlane(Vector3.down, hit.normal).normalized;

        // Aplicamos la fuerza de deslizamiento via ForceReceiver para que respete la gravedad existente
        ForceReceiver.AddForce(slideDir * slopeSlideSpeed * Time.deltaTime);
    }

    public void RotateColors()
    {
        Color tempColor = Mat_Player.material.GetColor("_ColorA");
        float tempFill = Mat_Player.material.GetFloat("_FillA");

        Mat_Player.material.SetColor("_ColorA", Mat_Player.material.GetColor("_ColorB"));
        Mat_Player.material.SetFloat("_FillA", Mat_Player.material.GetFloat("_FillB"));

        Mat_Player.material.SetColor("_ColorB", Mat_Player.material.GetColor("_ColorC"));
        Mat_Player.material.SetFloat("_FillB", Mat_Player.material.GetFloat("_FillC"));

        Mat_Player.material.SetColor("_ColorC", tempColor);
        Mat_Player.material.SetFloat("_FillC", tempFill);

        CheckAndSwitchColorState();
    }

    /// <summary>
    /// Llenar el color del shader del player por los pies
    /// </summary>
    /// <param name="newColor"></param>
    public void StartFill(Color newColor)
    {
        // Revisamos si ya tenemos este color a medio llenar (mayor a 0.01f y menor a 0.999f) para rellenarlo
        if (ColorsAreClose(Mat_Player.material.GetColor("_ColorA"), newColor) && Mat_Player.material.GetFloat("_FillA") > 0.01f && Mat_Player.material.GetFloat("_FillA") < 0.999f)
        {
            if (fillCoroutine != null) StopCoroutine(fillCoroutine);
            fillCoroutine = StartCoroutine(FillRoutine("_FillA"));
            return;
        }
        if (ColorsAreClose(Mat_Player.material.GetColor("_ColorB"), newColor) && Mat_Player.material.GetFloat("_FillB") > 0.01f && Mat_Player.material.GetFloat("_FillB") < 0.999f)
        {
            if (fillCoroutine != null) StopCoroutine(fillCoroutine);
            fillCoroutine = StartCoroutine(FillRoutine("_FillB"));
            return;
        }
        if (ColorsAreClose(Mat_Player.material.GetColor("_ColorC"), newColor) && Mat_Player.material.GetFloat("_FillC") > 0.01f && Mat_Player.material.GetFloat("_FillC") < 0.999f)
        {
            if (fillCoroutine != null) StopCoroutine(fillCoroutine);
            fillCoroutine = StartCoroutine(FillRoutine("_FillC"));
            return;
        }

        // Es una absorción nueva. Desplazamos hacia arriba si es necesario.
        float fillA = Mat_Player.material.GetFloat("_FillA");
        float fillB = Mat_Player.material.GetFloat("_FillB");
        float fillC = Mat_Player.material.GetFloat("_FillC");

        if (fillA < 0.1f)
        {
            Mat_Player.material.SetColor("_ColorA", newColor);
            Mat_Player.material.SetFloat("_FillA", 0.11f);
            StartFillRoutine("_FillA");
        }
        else if (fillB < 0.1f)
        {
            // A sube a B
            Mat_Player.material.SetColor("_ColorB", Mat_Player.material.GetColor("_ColorA"));
            Mat_Player.material.SetFloat("_FillB", Mat_Player.material.GetFloat("_FillA"));
            
            Mat_Player.material.SetColor("_ColorA", newColor);
            Mat_Player.material.SetFloat("_FillA", 0.11f);
            StartFillRoutine("_FillA");
        }
        else if (fillC < 0.1f)
        {
            // B sube a C, A sube a B
            Mat_Player.material.SetColor("_ColorC", Mat_Player.material.GetColor("_ColorB"));
            Mat_Player.material.SetFloat("_FillC", Mat_Player.material.GetFloat("_FillB"));

            Mat_Player.material.SetColor("_ColorB", Mat_Player.material.GetColor("_ColorA"));
            Mat_Player.material.SetFloat("_FillB", Mat_Player.material.GetFloat("_FillA"));
            
            Mat_Player.material.SetColor("_ColorA", newColor);
            Mat_Player.material.SetFloat("_FillA", 0.11f);
            StartFillRoutine("_FillA");
        }
        else
        {
            // Todos llenos, desplazamos todos hacia arriba (perdemos C)
            Mat_Player.material.SetColor("_ColorC", Mat_Player.material.GetColor("_ColorB"));
            Mat_Player.material.SetFloat("_FillC", Mat_Player.material.GetFloat("_FillB"));

            Mat_Player.material.SetColor("_ColorB", Mat_Player.material.GetColor("_ColorA"));
            Mat_Player.material.SetFloat("_FillB", Mat_Player.material.GetFloat("_FillA"));
            
            Mat_Player.material.SetColor("_ColorA", newColor);
            Mat_Player.material.SetFloat("_FillA", 0.11f);
            StartFillRoutine("_FillA");
        }
    }

    private void StartFillRoutine(string fillProperty)
    {
        if (fillCoroutine != null) StopCoroutine(fillCoroutine);
        fillCoroutine = StartCoroutine(FillRoutine(fillProperty));
        CheckAndSwitchColorState();
    }

    IEnumerator FillRoutine(string fillProperty)
    {
        while (Mat_Player.material.GetFloat(fillProperty) < 1f)
        {
            float currentFill = Mat_Player.material.GetFloat(fillProperty);
            float newFill = Mathf.Clamp01(currentFill + Time.deltaTime * fillSpeed);
            Mat_Player.material.SetFloat(fillProperty, newFill);
            yield return null;
        }

        CheckAndSwitchColorState();
    }


    public void UseColor(float reduceFill)
    {
        // Revisamos cuál es el primer Fill que tiene pintura, empezando por el C
        if (Mat_Player.material.GetFloat("_FillC") >= 0.1f)
        {
            StartCoroutine(EmptyColorRoutine(reduceFill, "_FillC"));
        }
        else if (Mat_Player.material.GetFloat("_FillB") >= 0.1f)
        {
            StartCoroutine(EmptyColorRoutine(reduceFill, "_FillB"));
        }
        else if (Mat_Player.material.GetFloat("_FillA") >= 0.1f)
        {
            StartCoroutine(EmptyColorRoutine(reduceFill, "_FillA"));
        }
    }

    IEnumerator EmptyColorRoutine(float reduceFill, string fillProperty)
    {
        float currentFill;
        float targetFill = Mat_Player.material.GetFloat(fillProperty) - reduceFill;
        
        // Si el objetivo baja del umbral (0.1f), forzamos que se vacíe por completo
        if (targetFill < 0.1f) 
        {
            targetFill = 0f;
        }

        while(Mat_Player.material.GetFloat(fillProperty) > targetFill)
        {
            currentFill = Mat_Player.material.GetFloat(fillProperty);
            currentFill -= (reduceFill * Time.deltaTime * 5f); // Multiplicado por 5f para que la animación de vaciado sea más rápida y fluida
            
            // Si nos pasamos bajando, lo ajustamos al objetivo elegido
            if (currentFill < targetFill) 
            {
                currentFill = targetFill;
            }
            
            Mat_Player.material.SetFloat(fillProperty, currentFill);
            yield return null;
        }

        CheckAndSwitchColorState();
    }

    public void CheckAndSwitchColorState()
    {
        // Revisamos C primero
        if (Mat_Player.material.GetFloat("_FillC") >= 0.1f) 
        {
            Color colorC = Mat_Player.material.GetColor("_ColorC");
            SwitchToStateByColor(colorC);
            return;
        }
        
        // Si C está vacío, revisamos B
        if (Mat_Player.material.GetFloat("_FillB") >= 0.1f) 
        {
            Color colorB = Mat_Player.material.GetColor("_ColorB");
            SwitchToStateByColor(colorB);
            return;
        }

        // Si B está vacío, revisamos A
        if (Mat_Player.material.GetFloat("_FillA") >= 0.1f) 
        {
            Color colorA = Mat_Player.material.GetColor("_ColorA");
            SwitchToStateByColor(colorA);
            return;
        }

        // Si los 3 están vacíos, al estado por defecto:
        SwitchState(typeof(PlayerWhiteState));
    }

    private void SwitchToStateByColor(Color c)
    {
        // En Unity a veces los colores del shader tienen ligeras variaciones de flotantes
        // Buscamos una coincidencia aproximada
        bool stateFound = false;
        Type targetState = null;

        foreach (var kvp in colorToStateDic)
        {
            if (ColorsAreClose(kvp.Key, c))
            {
                targetState = kvp.Value;
                stateFound = true;
                break;
            }
        }

        if (!stateFound)
        {
            AudioManager.Instance?.SetInkState(InkStateType.Base);
            SwitchState(typeof(PlayerWhiteState));
            return;
        }


        Type currentState = GetCurrentState().GetType();

        if (currentState == targetState) return;
        if (targetState == typeof(PlayerRedState) && currentState == typeof(PlayerShootingState)) return;
        if (targetState == typeof(PlayerGreenState) && currentState == typeof(PlayerWhipState)) return;
        if (targetState == typeof(PlayerBlueState) && currentState == typeof(PlayerGeyserState)) return;

        UpdateInkAudioForState(targetState);
        SwitchState(targetState);
    }

    private bool ColorsAreClose(Color a, Color b)
    {
        float tolerance = 0.05f; // Margen de error para pequeñas discrepancias del shader
        return Mathf.Abs(a.r - b.r) <= tolerance &&
               Mathf.Abs(a.g - b.g) <= tolerance &&
               Mathf.Abs(a.b - b.b) <= tolerance &&
               Mathf.Abs(a.a - b.a) <= tolerance;
    }

    public void AddShadowDrop()
    {
        Ray ray = new Ray(transform.position, Vector3.down);

        if (!Physics.Raycast(ray, out RaycastHit hit, MaxDistance, groundMask))
        {
            ShadowDrop.gameObject.SetActive(false);
            return;
        }

        ShadowDrop.gameObject.SetActive(true);

        float t = hit.distance / MaxDistance;


        ShadowDrop.position = hit.point;// + hit.normal * OffsetY;
        ShadowDrop.position += new Vector3(0f, OffsetY,0f);
    }


    public float GetCurrentCameraSensitivity()
    {
        return InputReader.IsUsingGamepad ? GamepadAimSensitivity : MiceAimSensitivity;
    }
    
    // TODO: Move to dedicated script
    private void OnDrawGizmosSelected()
    {
        if (groundCheckOrigin == null) return;

        Gizmos.color = Color.green;
        
        Gizmos.DrawWireSphere(groundCheckOrigin.position, groundCheckRadius);
        
        Vector3 castDirection = Vector3.down * groundCheckDistance;
        
        Vector3 endPosition = groundCheckOrigin.position + castDirection;
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(endPosition, groundCheckRadius);
        
        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(groundCheckOrigin.position, endPosition);
        
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

    //helper audio 
    private void UpdateInkAudioForState(Type targetState)
    {
        if (targetState == typeof(PlayerWhiteState))
            AudioManager.Instance?.SetInkState(InkStateType.Base);
        else if (targetState == typeof(PlayerRedState))
            AudioManager.Instance?.SetInkState(InkStateType.Red);
        else if (targetState == typeof(PlayerBlueState))
            AudioManager.Instance?.SetInkState(InkStateType.Blue);
        else if (targetState == typeof(PlayerGreenState))
            AudioManager.Instance?.SetInkState(InkStateType.Green);
    }
}
