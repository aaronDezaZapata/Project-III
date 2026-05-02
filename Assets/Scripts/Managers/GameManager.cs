using System;
using System.Collections.Generic;
using Unity.Cinemachine;
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    [SerializeField] private Transform player;
    
    public static GameManager Instance;
    
    public List<GameObject> levelDecals;

    public GameObject paintBeacon;

    private Transform currentCheckPoint;

    public Action<string> OnLeverActivated;

    // Cinemática portal
    [SerializeField] private CinemachineCamera gameplayCamera;
    [SerializeField] private CinemachineCamera portalCinematicCamera;
    [SerializeField] private int gameplayCameraPriority = 10;
    [SerializeField] private int portalCameraPriority = 20;
    [SerializeField] private float delayBeforePortalOpens = 1f;
    [SerializeField] private float cinematicDuration = 3f;

    [Header("Portal Camera Movement")]
    [SerializeField] private Transform portalCameraMoveTransform;
    [SerializeField] private Vector3 portalCameraStartOffset = new Vector3(0f, 1.5f, -1.5f);
    [SerializeField] private Vector3 portalCameraEndOffset = new Vector3(0f, -0.3f, 0.4f);
    [SerializeField] private float cameraMoveDuration = 2f;

    private bool isPortalCinematicPlaying = false;
    private bool portalHasOpenedDuringCinematic = false;
    private float portalCinematicTimer = 0f;
    private Vector3 portalCameraBasePosition;
    private bool hasPortalCameraBasePosition = false;

    // Coins
    private int coinsCollected = 0;


    [SerializeField] private int totalStarsNeeded = 6;
    [SerializeField] private int starsCollected = 0;
    [SerializeField] private PortalController portal;


    private bool portalOpened = false;
    

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(this);
            return;
        }

        if (currentCheckPoint == null) return;
        GetNewCheckPoint(currentCheckPoint);
    }

    public Transform GetPlayer()
    {
        return player;
    }

    public State GetPlayerState()
    {
        return GetPlayer().GetComponent<StateMachine>().GetCurrentState(); // ya existe en StateMachine.cs
    }

    public void SetPlayerState<T>() where T : State
    {
        GetPlayer().GetComponent<StateMachine>().SwitchState(typeof(T));
    }

    public void RemoveCurrentDecals()
    {
        foreach (GameObject decal in levelDecals)
        {
            Destroy(decal);
        }
        
        levelDecals.Clear();
    }
    
    public void GetNewCheckPoint(Transform newCheckPoint)
    {
        currentCheckPoint = newCheckPoint;
    }

    public void AddCoin(int amount)
    {
        coinsCollected += amount;
    }

    public void CollectStar(int amount)
    {
        starsCollected += amount;
        Debug.Log("Stars Collected: " + starsCollected + "/" + totalStarsNeeded);

        if (!portalOpened && starsCollected >= totalStarsNeeded)
        {
            portalOpened = true;

            if (portal != null)
            {
                StartPortalUnlockCinematic();
            }
            else
            {
                Debug.LogWarning("Portal no asignado en el GameManager.");
            }
        }
    }

    private void StartPortalUnlockCinematic()
    {
        isPortalCinematicPlaying = true;
        portalHasOpenedDuringCinematic = false;
        portalCinematicTimer = 0f;

        if (player != null)
        {
            PlayerStateMachine playerStateMachine = player.GetComponent<PlayerStateMachine>();

            if (playerStateMachine != null)
                playerStateMachine.enabled = false;

            Rigidbody rb = player.GetComponent<Rigidbody>();

            if (rb != null)
            {
                rb.linearVelocity = Vector3.zero;
                rb.angularVelocity = Vector3.zero;
            }
        }

        if (gameplayCamera != null)
            gameplayCamera.Priority = 0;

        if (portalCinematicCamera != null)
            portalCinematicCamera.Priority = portalCameraPriority;

        if (portalCameraMoveTransform != null)
        {
            portalCameraBasePosition = portalCameraMoveTransform.position;
            hasPortalCameraBasePosition = true;

            portalCameraMoveTransform.position = portalCameraBasePosition + portalCameraStartOffset;
        }
    }

    private void UpdatePortalUnlockCinematic()
    {
        if (!isPortalCinematicPlaying) return;

        portalCinematicTimer += Time.deltaTime;

        UpdatePortalCameraMovement();

        if (!portalHasOpenedDuringCinematic && portalCinematicTimer >= delayBeforePortalOpens)
        {
            portalHasOpenedDuringCinematic = true;
            portal.OpenPortal();
        }

        if (portalHasOpenedDuringCinematic && portal != null && portal.IsRevealFinished)
        {
            if (portalCinematicTimer >= delayBeforePortalOpens + cinematicDuration)
            {
                EndPortalUnlockCinematic();
            }
        }
    }

    private void UpdatePortalCameraMovement()
    {
        if (portalCameraMoveTransform == null) return;
        if (!hasPortalCameraBasePosition) return;

        float t = portalCinematicTimer / cameraMoveDuration;
        t = Mathf.Clamp01(t);

        t = Mathf.SmoothStep(0f, 1f, t);

        Vector3 startPosition = portalCameraBasePosition + portalCameraStartOffset;
        Vector3 endPosition = portalCameraBasePosition + portalCameraEndOffset;

        portalCameraMoveTransform.position = Vector3.Lerp(startPosition, endPosition, t);
    }

    private void EndPortalUnlockCinematic()
    {
        if (portalCinematicCamera != null)
            portalCinematicCamera.Priority = 0;

        if (gameplayCamera != null)
            gameplayCamera.Priority = gameplayCameraPriority;

        // Esconder shards 
        if (portal != null)
            portal.HideShards();

        if (player != null)
        {
            PlayerStateMachine playerStateMachine = player.GetComponent<PlayerStateMachine>();

            if (playerStateMachine != null)
                playerStateMachine.enabled = true;
        }

        isPortalCinematicPlaying = false;
    }


    public void ResetCoinAmount()
    {
        coinsCollected = 0;
    }

    private void Update()
    {
        UpdatePortalUnlockCinematic();

        if (isPortalCinematicPlaying) return;

        // L3 + R3 simultáneamente es toggle FlyState debug
        bool leftStick = Input.GetKeyDown(KeyCode.JoystickButton8);
        bool rightStick = Input.GetKey(KeyCode.JoystickButton9);

        if (leftStick && rightStick)
        {
            if (GetPlayerState() is PlayerFlyState)
            {
                player.GetComponent<PlayerStateMachine>().ReturnToMainState();
            }
            else
            {
                SetPlayerState<PlayerFlyState>();
            }
        }
    }

    public void PlayerDeath()
    {
        player.transform.position = currentCheckPoint.transform.position;
        player.transform.rotation = currentCheckPoint.transform.rotation;
    }
}
