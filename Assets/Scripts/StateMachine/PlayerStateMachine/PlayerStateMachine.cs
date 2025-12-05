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

  

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        AddState(new PlayerFreeLookState(this));

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

}
