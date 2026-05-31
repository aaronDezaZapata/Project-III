using System;
using Unity.Cinemachine;
using UnityEngine;

public class PlayerStateMachine : StateMachine
{
    #region Variables

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
    [field: SerializeField] public CinemachineCamera MainCamera { get; private set; }
    [field: SerializeField] public CinemachineCamera AimCamera { get; private set; }
    [field: SerializeField] public PitchCameraControl AimCameraPitchControl { get; private set; }
    [field: SerializeField] public SkinnedMeshRenderer MatPlayer { get; private set; }

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

    [field: Header("Aim Camera Sensitivity")]
    [field: Range(0.1f, 5f)]
    [field: SerializeField] public float MiceAimSensitivity { get; set; } = 1f;
    [field: Range(0.1f, 5f)]
    [field: SerializeField] public float GamepadAimSensitivity { get; set; } = 3f;
    [field: SerializeField] public bool AimXAxisInverted { get; set; }

    [field: Header("Movement Variables")]
    [field: SerializeField] public float FreeLookMovementSpeed { get; private set; }
    [field: SerializeField] public float RotationSpeed { get; private set; } = 3f;
    [field: SerializeField] public float JumpForce { get; private set; }

    [field: Header("Double Jump Settings")]
    [field: SerializeField] public bool HasDoubleJump { get; private set; } = true;
    [field: SerializeField] public float DoubleJumpForce { get; private set; } = 15f;

    [field: Header("Jump Timing")]
    [field: SerializeField] public float CoyoteTime { get; private set; } = 0.15f;
    [field: SerializeField] public float AccelerationTime { get; private set; } = 0.1f;
    [field: SerializeField] public float DecelerationTime { get; private set; } = 0.2f;

    [field: Header("Direction Change Settings")]
    [field: SerializeField] public float DirectionChangeThreshold { get; private set; } = 90f;
    [field: SerializeField] public float QuickStopTime { get; private set; } = 0.05f;
    [field: SerializeField] public float QuickStopSpeedThreshold { get; private set; } = 0.3f;

    [Header("Ground Check")]
    [SerializeField] public float groundCheckDistance = 0.2f;
    [SerializeField] public float groundCheckRadius = 0.3f;
    [SerializeField] public LayerMask groundMask;
    [SerializeField] public Transform groundCheckOrigin;
    [SerializeField] public float slopeSlideSpeed = 8f;

    public bool isGrounded;
    public bool isOnSteepSlope;

    [field: Header("Particles")]
    [field: SerializeField] public ParticleSystem FootstepParticles1 { get; private set; }
    [field: SerializeField] public ParticleSystem FootstepParticles2 { get; private set; }
    [field: SerializeField] public ParticleSystem LandingParticles { get; private set; }
    [field: SerializeField] public float MinFallVelocityToPlayLandingParticle { get; private set; } = 5f;

    [field: Header("Swim Mechanics")]
    [field: SerializeField] public float SwimSpeed { get; private set; } = 12f;
    [field: SerializeField] public float WallJumpForce { get; private set; } = 15f;
    [field: Range(0f, 90f)]
    [field: SerializeField] public float WallJumpAngle { get; private set; } = 30f;
    [field: SerializeField] public GameObject inkDecalPrefab;
    [field: SerializeField] public LayerMask inkLayer;

    public bool _isOnInk;
    public Vector3 currentInkNormal = Vector3.up;

    [HideInInspector] public bool whipFailedLastAttempt;

    [field: Header("Green Grapple Mechanics")]
    [field: SerializeField] public float MaxGrappleDistance { get; private set; } = 25f;
    [field: SerializeField] public float SwingRadius { get; private set; } = 5f;
    [field: SerializeField] public float MinSwingSpeed { get; private set; } = 2f;
    [field: SerializeField] public float SwingInputForce { get; private set; } = 5f;
    [field: SerializeField] public float GrappleJumpForce { get; private set; } = 8f;
    [field: SerializeField] public LayerMask GrappleObstacleLayer { get; private set; } = ~0;
    [field: SerializeField] public LineRenderer GrappleRope { get; private set; }
    [field: SerializeField] public Transform GrappleRopeOrigin { get; private set; }

    [Header("References")]
    [field: SerializeField] public Transform FirePoint { get; private set; }
    [field: SerializeField] public Transform WaterGeyserParticle { get; private set; }
    [field: SerializeField] public Transform WaterGeyserParticleSecond { get; private set; }
    [field: SerializeField] public Rigidbody ProjectilePrefab { get; private set; }
    [field: SerializeField] public float FireCooldown { get; private set; } = 0.15f;

    [field: Header("Shooting Config")]
    [field: SerializeField] public float aimMovementSpeed = 3f;
    [field: SerializeField] public float horizontalSensitivity = 150f;
    [field: SerializeField] public float verticalSensitivity = 100f;
    [field: SerializeField] public float minVerticalAngle = -60f;
    [field: SerializeField] public float maxVerticalAngle = 60f;
    [field: SerializeField] public float ReticleSurfaceOffset { get; private set; } = 0.02f;

    [field: Header("Geyser Settings")]
    [field: SerializeField] public float HoverForce { get; private set; } = 15f;
    [field: SerializeField] public float AerialMoveSpeed { get; private set; } = 10f;
    [field: SerializeField] public float GeyserCooldownTime { get; private set; } = 1f;

    [HideInInspector] public float geyserCooldownTimer;
    [HideInInspector] public bool isGeyserOnCooldown;
    
    private PlayerGroundChecker _groundChecker;
    private PlayerInkColorSystem _inkColorSystem;
    private PlayerTriggerHandler _triggerHandler;
    private GrapplePoint _grapplePoint;
    private GrapplePoint _secondaryGrapplePoint;

    public GrapplePoint SecondaryGrapplePoint
    {
        get => _secondaryGrapplePoint;
        set => _secondaryGrapplePoint = value;
    }

    public GrapplePoint GrapplePoint
    {
        get => _grapplePoint;
        set => _grapplePoint = value;
    }

    #endregion
    
    private void Awake()
    {
        if (PlayerAudio == null)
            PlayerAudio = GetComponentInChildren<PlayerAudio>();

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

        _groundChecker = GetComponent<PlayerGroundChecker>();
        _inkColorSystem = GetComponent<PlayerInkColorSystem>();
        _triggerHandler = GetComponent<PlayerTriggerHandler>();
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

        SwitchState(typeof(PlayerWhiteState));
    }

    public void ReturnToMainState()
    {
        switch (playerState)
        {
            case PlayerStates.WHITE: SwitchState(typeof(PlayerWhiteState)); break;
            case PlayerStates.RED:   SwitchState(typeof(PlayerRedState));   break;
            case PlayerStates.BLUE:  SwitchState(typeof(PlayerBlueState));  break;
            case PlayerStates.GREEN: SwitchState(typeof(PlayerGreenState)); break;
            case PlayerStates.FLY: SwitchState(typeof(PlayerWhiteState)); break;
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
            ForceReceiver.AddForce(pushDirection.normalized * pushForce);
    }

    private void OnControllerColliderHit(ControllerColliderHit hit)
    {
        if (hit.transform.CompareTag("Insta"))
            GameManager.Instance.PlayerDeath();
    }
    
    public Vector3 CalculateMovement()
    {
        Vector3 forward = Camera.main.transform.forward;
        Vector3 right   = Camera.main.transform.right;

        forward.y = 0f;
        right.y   = 0f;

        forward.Normalize();
        right.Normalize();

        return forward * InputReader.MoveVector.y + right * InputReader.MoveVector.x;
    }

    public float GetCurrentCameraSensitivity()
    {
        return InputReader.IsUsingGamepad ? GamepadAimSensitivity : MiceAimSensitivity;
    }
    
    public void CheckGrounded()           => _groundChecker.CheckGrounded();
    public void ApplySlopeSlide()         => _groundChecker.ApplySlopeSlide();
    public void PlayFootstepParticle()    => _groundChecker.PlayFootstepParticle();

    public void RotateColors()                        => _inkColorSystem.RotateColors();
    public void StartFill(Color newColor)             => _inkColorSystem.StartFill(newColor);
    public void UseColor(float reduceFill)            => _inkColorSystem.UseColor(reduceFill);

    public void HandlePuddleInteraction()                       => _triggerHandler.HandlePuddleInteraction();
    public void CheckForInk()                                   => _triggerHandler.CheckForInk();
    public void PaintSurface(Vector3 point, Vector3 normal)     => _triggerHandler.PaintSurface(point, normal);

    public void SetGrapplePoint(GrapplePoint grapplePoint)
    {
        if (GrapplePoint == null)
        {
            GrapplePoint = grapplePoint;
        }
        else
        {
            SecondaryGrapplePoint = grapplePoint;
        }
    }

    public GrapplePoint GetGrapplePoint()
    {
        if (_grapplePoint)
            return _grapplePoint;
        if (_secondaryGrapplePoint)
            return _secondaryGrapplePoint;
        return null;
    }
    
    public void RemoveGrapplePoint(GrapplePoint grapplePoint)
    {
        if (_grapplePoint == grapplePoint)
            _grapplePoint = null;
        if (_secondaryGrapplePoint == grapplePoint)
            _secondaryGrapplePoint = null;
    }
}
