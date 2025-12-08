using System.Collections;
using System.Collections.Generic;
using Unity.Cinemachine;
using UnityEngine;

public class PlayerStateMachine : StateMachine
{
    [field: SerializeField] public InputHandler InputReader { get; private set; }

    [field: SerializeField] public CharacterController Controller { get; private set; }
    [field: SerializeField] public ForceReceiver ForceReceiver { get; private set; }
    [field: SerializeField] public Animator Animator { get; private set; }

    [field: SerializeField] public CinemachineCamera camera_CM { get; private set; }

    [field: SerializeField] public Health Health { get; private set; }

    [field: SerializeField] public float FreeLookMovementSpeed { get; private set; }

    [field: SerializeField] public float RotationSpeed { get; private set; } = 3f;

    [field: SerializeField] public float DashDuration { get; private set; }

    [field: SerializeField] public float DashLength { get; private set; }

    [field: SerializeField] public float JumpForce { get; private set; }

    [field: SerializeField] public float AccelerationTime { get; private set; } = 0.1f;

    [field: SerializeField] public float DecelerationTime { get; private set; } = 0.2f;


    [field: Header("Splatoon Mechanics")]
    [field: SerializeField] public float SwimSpeed { get; private set; } = 12f; // Velocidad al nadar
    [field: SerializeField] public GameObject InkDecalPrefab; // Arrastra tu prefab aquí
    [field: SerializeField] public LayerMask InkLayer;        // Selecciona la layer "Ink"
    [field: SerializeField] public Transform GunOrigin;       // Opcional: si quieres un punto exacto, si no usaremos la cámara

    // Estado compartido para saber si estamos sobre tinta
    public bool IsOnInk;
    public Vector3 CurrentInkNormal = Vector3.up;
    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        AddState(new PlayerFreeLookState(this));
        AddState(new PlayerSwimState(this));
        SwitchState(typeof(PlayerFreeLookState));
    }

    public void StartCameraShake(float duration)
    {
        StartCoroutine(ShakeRoutine(duration));
    }

    /*
    private void Update()
    {
        
    }
    */
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
        // 1. CLAVE: Usamos el centro real del CharacterController en el mundo, no los pies.
        // TransformPoint convierte el centro local (0, 0.25, 0) a una posición real en el mundo 3D.
        Vector3 detectionOrigin = transform.TransformPoint(Controller.center);

        // 2. RADIO: 0.7f u 0.8f está bien.
        Collider[] hitColliders = Physics.OverlapSphere(detectionOrigin, 0.7f, InkLayer);

        if (hitColliders.Length > 0)
        {
            IsOnInk = true;

            RaycastHit hit;

            // Lanzamos el rayo también desde el centro para mayor precisión
            // "detectionOrigin" es el centro del cuerpo.
            // "-transform.up" busca la superficie bajo nuestros pies/ventosa.
            if (Physics.Raycast(detectionOrigin, -transform.up, out hit, 1.5f, InkLayer))
            {
                CurrentInkNormal = hit.normal;
            }
            else
            {
                // Si el rayo falla (común en esquinas raras), usamos tu truco del forward del decal
                CurrentInkNormal = hitColliders[0].transform.forward * -1f;
            }
        }
        else
        {
            IsOnInk = false;
            CurrentInkNormal = Vector3.up;
        }
    }

    // Helper para instanciar tinta (llamado desde los estados)
    public void ShootInk()
    {
        Ray ray = new Ray(Camera.main.transform.position, Camera.main.transform.forward);
        RaycastHit hit;

        int layerMask = ~LayerMask.GetMask("Player", "Ink", "UI");

        if (Physics.Raycast(ray, out hit, 100f, layerMask))
        {
            // --- CÁLCULO DE ROTACIÓN PARA EL DECAL ---

            // 1. Obtener la rotación necesaria para alinear el Eje Y del objeto con la Normal de impacto
            // Esto es correcto: el Eje Y apunta "hacia afuera" de la superficie
            Quaternion alignmentRotation = Quaternion.FromToRotation(Vector3.up, hit.normal);

            // 2. Aplicar una rotación adicional de 180° en el Eje X
            // Esto voltea el objeto para que su Eje Z (el de proyección) mire hacia la superficie
            Quaternion fixRotation = Quaternion.Euler(90f, 0f, 0f);

            // Rotación final: Primero alinear, luego voltear el eje de proyección
            Quaternion finalRotation = alignmentRotation * fixRotation;

            // Instanciar el Decal
            GameObject splat = Instantiate(InkDecalPrefab, hit.point, finalRotation);

            // Pequeño offset para evitar Z-Fighting visual
            splat.transform.position += hit.normal * 0.01f;
        }
    }

}
