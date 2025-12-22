using System.Collections;
using System.Collections.Generic;
using Unity.Cinemachine;
using UnityEngine;

public class PlayerStateMachine : StateMachine
{
    #region Variables
    
    [field: Header("Getters and Setters")]
    [field: SerializeField] public InputHandler InputReader { get; private set; }

    [field: SerializeField] public CharacterController Controller { get; private set; }
    [field: SerializeField] public ForceReceiver ForceReceiver { get; private set; }
    [field: SerializeField] public Animator Animator { get; private set; }

    [field: SerializeField] public CinemachineCamera camera_CM { get; private set; }

    [field: SerializeField] public CinemachineCamera aimCamera { get; private set; }

    [field: SerializeField] public Health Health { get; private set; }
    
    [field: Header("Movement Variables")]
    [field: SerializeField] public float FreeLookMovementSpeed { get; private set; }

    [field: SerializeField] public float RotationSpeed { get; private set; } = 3f;

    [field: SerializeField] public float DashDuration { get; private set; }

    [field: SerializeField] public float DashLength { get; private set; }

    [field: SerializeField] public float JumpForce { get; private set; }

    [field: SerializeField] public float AccelerationTime { get; private set; } = 0.1f;

    [field: SerializeField] public float DecelerationTime { get; private set; } = 0.2f;


    [field: Header("Splatoon Mechanics")]
    [field: SerializeField] public float SwimSpeed { get; private set; } = 12f; 
    [field: SerializeField] public GameObject InkDecalPrefab; 
    [field: SerializeField] public LayerMask InkLayer;        
    [field: SerializeField] public Transform GunOrigin;       
    [SerializeField] public Transform reticle { get; private set; } // Quad o Canvas


    public bool IsOnInk;
    public Vector3 CurrentInkNormal = Vector3.up;

    #endregion


    [Header("References")]

    [field: SerializeField] public Transform FirePoint { get; private set; }
    [field: SerializeField] public Rigidbody ProjectilePrefab { get; private set; }
    [field: SerializeField] public float FireCooldown { get; private set; } = 0.15f;
    [field: SerializeField] public float ProjectileFlightTime { get; private set; } = 0.6f;
    [field: SerializeField] public LayerMask PaintableLayer { get; private set; } = ~0;

    [field: Header("Reticle Config")]
    [field: SerializeField] public Transform ReticleTransform { get; private set; } // El objeto visual de la mira
    [field: SerializeField] public float MaxAimDistance { get; private set; } = 80f;
    [field: SerializeField] public LayerMask AimLayerMask { get; private set; } = ~0;
    [field: SerializeField] public float ReticleSurfaceOffset { get; private set; } = 0.02f;

    [field: Header("Heiser")]
    [field: SerializeField] public float HoverForce { get; private set; } = 15f; // subir mas/menos rapido
    [field: SerializeField] public float aerialMoveSpeed { get; private set; } = 10f;

    // Esta variable controla que solo se use una vez por aire
    public bool CanHeiser { get; set; } = true;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        AddState(new PlayerFreeLookState(this));
        AddState(new PlayerSwimState(this));
        AddState(new PlayerShootingState(this));
        AddState(new PlayerHeiserState(this));
        SwitchState(typeof(PlayerFreeLookState));
    }

    public void StartCameraShake(float duration)
    {
        StartCoroutine(ShakeRoutine(duration));
    }

    public IEnumerator ShakeRoutine(float duration)
    {
        camera_CM.GetComponent<CinemachineBasicMultiChannelPerlin>().AmplitudeGain = 5f;
        camera_CM.GetComponent<CinemachineBasicMultiChannelPerlin>().FrequencyGain = 2f;
        float elapsed = 0f;


        // Gradually reduce shake over time
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            


            yield return null;
        }

        camera_CM.GetComponent<CinemachineBasicMultiChannelPerlin>().AmplitudeGain = 0f;
        camera_CM.GetComponent<CinemachineBasicMultiChannelPerlin>().FrequencyGain = 0f;
    }

    private void OnEnable()
    {
       
    }

    private void OnDisable()
    {
 
    }

    void HandleTakeDamage()
    {
        //SwitchState(PlayerImpactState);
    }

    void HandleDie()
    {
       // SwitchState( PlayerDeadState);
    }


    public void CheckForInk()
    {
        //  Usamos el centro real del CharacterController en el mundo, no los pies.
        
        Vector3 detectionOrigin = transform.TransformPoint(Controller.center);

        // 2. RADIO: 0.7f u 0.8f est� bien.
        Collider[] hitColliders = Physics.OverlapSphere(detectionOrigin, 0.7f, InkLayer);

        if (hitColliders.Length > 0)
        {
            IsOnInk = true;

            RaycastHit hit;

            // Lanzamos el rayo tambi�n desde el centro para mayor precisi�n
            // "detectionOrigin" es el centro del cuerpo.
            // "-transform.up" busca la superficie bajo nuestros pies/ventosa.
            if (Physics.Raycast(detectionOrigin, -transform.up, out hit, 1.5f, InkLayer))
            {
                CurrentInkNormal = hit.normal;
            }
            else
            {
                // Si el rayo falla (com�n en esquinas raras), usamos tu truco del forward del decal
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

        // Lógica traída de InkDecalPainter
        Quaternion alignmentRotation = Quaternion.FromToRotation(Vector3.up, normal);
        Quaternion fixRotation = Quaternion.Euler(90f, 0f, 0f); // Ajuste si tu decal está rotado
        Quaternion finalRotation = alignmentRotation * fixRotation;

        GameObject splat = Instantiate(InkDecalPrefab, point, finalRotation);
        splat.transform.position += normal * ReticleSurfaceOffset;
    }

    // Helper para instanciar tinta (llamado desde los estados)
    public void ShootInk()
    {
        Ray ray = new Ray(Camera.main.transform.position, Camera.main.transform.forward);
        RaycastHit hit;

        int layerMask = ~LayerMask.GetMask("Player", "Ink", "UI");

        if (Physics.Raycast(ray, out hit, 100f, layerMask))
        {
           
            Quaternion alignmentRotation = Quaternion.FromToRotation(Vector3.up, hit.normal);

            
            // Esto voltea el objeto para que su Eje Z (el de proyecci�n) mire hacia la superficie
            Quaternion fixRotation = Quaternion.Euler(90f, 0f, 0f);

            //Primero alinear, luego voltear el eje de proyecci�n
            Quaternion finalRotation = alignmentRotation * fixRotation;

            
            GameObject splat = Instantiate(InkDecalPrefab, hit.point, finalRotation);

            // Peque�o offset para evitar Z-Fighting visual
            splat.transform.position += hit.normal * 0.01f;
        }
    }
}
