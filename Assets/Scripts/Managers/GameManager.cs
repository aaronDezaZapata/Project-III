using System;
using System.Collections.Generic;
using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    [SerializeField] private Transform _player;
    [SerializeField] private List<GameObject> _levelDecals;

    private GameObject _paintBeacon;
    public GameObject PaintBeacon
    {
        get => _paintBeacon;
        set => _paintBeacon = value;
    }

    private Transform _currentCheckPoint;

    public Action<string> OnLeverActivated;

    [SerializeField] private CinemachineCamera _gameplayCamera;
    [SerializeField] private CinemachineCamera _portalCinematicCamera;
    [SerializeField] private int _gameplayCameraPriority = 10;
    [SerializeField] private int _portalCameraPriority = 20;
    [SerializeField] private float _delayBeforePortalOpens = 1f;
    [SerializeField] private float _cinematicDuration = 3f;

    [Header("Portal Camera Movement")]
    [SerializeField] private Transform _portalCameraMoveTransform;
    [SerializeField] private Vector3 _portalCameraStartOffset = new Vector3(0f, 1.5f, -1.5f);
    [SerializeField] private Vector3 _portalCameraEndOffset   = new Vector3(0f, -0.3f, 0.4f);
    [SerializeField] private float _cameraMoveDuration = 2f;

    private bool _isPortalCinematicPlaying;
    private bool _portalHasOpenedDuringCinematic;
    private float _portalCinematicTimer;
    private Vector3 _portalCameraBasePosition;
    private bool _hasPortalCameraBasePosition;

    private int _coinsCollected;

    [SerializeField] private int _totalStarsNeeded = 6;
    [SerializeField] private int _starsCollected;
    [SerializeField] private PortalController _portal;

    private bool _portalOpened;

    [SerializeField] TextMeshPro _currentCollectibles;
    [SerializeField] TextMeshPro _totalCollectibles;
    

    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
        {
            Destroy(this);
            return;
        }

        if (_currentCheckPoint == null) return;
        GetNewCheckPoint(_currentCheckPoint);
        _currentCollectibles.text = _starsCollected.ToString();
        _totalCollectibles.text = _totalStarsNeeded.ToString();
    }

    public Transform GetPlayer() => _player;

    public State GetPlayerState()
    {
        return GetPlayer().GetComponent<StateMachine>().GetCurrentState();
    }

    public void SetPlayerState<T>() where T : State
    {
        GetPlayer().GetComponent<StateMachine>().SwitchState(typeof(T));
    }

    public void RemoveCurrentDecals()
    {
        foreach (GameObject decal in _levelDecals)
            Destroy(decal);

        _levelDecals.Clear();
    }

    public void GetNewCheckPoint(Transform newCheckPoint)
    {
        _currentCheckPoint = newCheckPoint;
    }

    public void AddCoin(int amount)
    {
        _coinsCollected += amount;
    }

    public void CollectStar(int amount)
    {
        _starsCollected += amount;
        _currentCollectibles.text = _starsCollected.ToString();
        Debug.Log("Stars Collected: " + _starsCollected + "/" + _totalStarsNeeded);

        if (!_portalOpened && _starsCollected >= _totalStarsNeeded)
        {
            _portalOpened = true;

            if (_portal != null)
                StartPortalUnlockCinematic();
            else
                Debug.LogWarning("Portal no asignado en el GameManager.");
        }
    }

    private void StartPortalUnlockCinematic()
    {
        _isPortalCinematicPlaying = true;
        _portalHasOpenedDuringCinematic = false;
        _portalCinematicTimer = 0f;

        if (_player != null)
        {
            PlayerStateMachine playerStateMachine = _player.GetComponent<PlayerStateMachine>();
            if (playerStateMachine != null)
                playerStateMachine.enabled = false;

            Rigidbody rb = _player.GetComponent<Rigidbody>();
            if (rb != null)
            {
                rb.linearVelocity  = Vector3.zero;
                rb.angularVelocity = Vector3.zero;
            }
        }

        if (_gameplayCamera != null)
            _gameplayCamera.Priority = 0;

        if (_portalCinematicCamera != null)
            _portalCinematicCamera.Priority = _portalCameraPriority;

        if (_portalCameraMoveTransform != null)
        {
            _portalCameraBasePosition = _portalCameraMoveTransform.position;
            _hasPortalCameraBasePosition = true;
            _portalCameraMoveTransform.position = _portalCameraBasePosition + _portalCameraStartOffset;
        }
    }

    private void UpdatePortalUnlockCinematic()
    {
        if (!_isPortalCinematicPlaying) return;

        _portalCinematicTimer += Time.deltaTime;

        UpdatePortalCameraMovement();

        if (!_portalHasOpenedDuringCinematic && _portalCinematicTimer >= _delayBeforePortalOpens)
        {
            _portalHasOpenedDuringCinematic = true;
            _portal.OpenPortal();
        }

        if (_portalHasOpenedDuringCinematic && _portal != null && _portal.IsRevealFinished)
        {
            if (_portalCinematicTimer >= _delayBeforePortalOpens + _cinematicDuration)
                EndPortalUnlockCinematic();
        }
    }

    private void UpdatePortalCameraMovement()
    {
        if (_portalCameraMoveTransform == null || !_hasPortalCameraBasePosition) return;

        float t = Mathf.SmoothStep(0f, 1f, Mathf.Clamp01(_portalCinematicTimer / _cameraMoveDuration));

        Vector3 startPosition = _portalCameraBasePosition + _portalCameraStartOffset;
        Vector3 endPosition   = _portalCameraBasePosition + _portalCameraEndOffset;

        _portalCameraMoveTransform.position = Vector3.Lerp(startPosition, endPosition, t);
    }

    private void EndPortalUnlockCinematic()
    {
        if (_portalCinematicCamera != null)
            _portalCinematicCamera.Priority = 0;

        if (_gameplayCamera != null)
            _gameplayCamera.Priority = _gameplayCameraPriority;

        if (_portal != null)
            _portal.HideShards();

        if (_player != null)
        {
            PlayerStateMachine playerStateMachine = _player.GetComponent<PlayerStateMachine>();
            if (playerStateMachine != null)
                playerStateMachine.enabled = true;
        }

        _isPortalCinematicPlaying = false;
    }

    public void ResetCoinAmount()
    {
        _coinsCollected = 0;
    }

    private void Update()
    {
        UpdatePortalUnlockCinematic();

        if (_isPortalCinematicPlaying) return;

        bool leftStick  = Input.GetKeyDown(KeyCode.JoystickButton8);
        bool rightStick = Input.GetKey(KeyCode.JoystickButton9);

        if (leftStick && rightStick)
        {
            if (GetPlayerState() is PlayerFlyState)
                _player.GetComponent<PlayerStateMachine>().ReturnToMainState();
            else
                SetPlayerState<PlayerFlyState>();
        }
    }

    public void PlayerDeath()
    {
        _player.transform.position = _currentCheckPoint.transform.position;
        _player.transform.rotation = _currentCheckPoint.transform.rotation;
    }
}
