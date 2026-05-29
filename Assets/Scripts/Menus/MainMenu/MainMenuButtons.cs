using System;
using System.Collections;
using FMOD.Studio;
using FMODUnity;
using UnityEngine;
using UnityEngine.SceneManagement;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class MainMenuButtons : MonoBehaviour
{
    [Header("Camera / Object To Move")]
    [SerializeField] private Transform _objectToMove;

    [Header("Menu Positions")]
    [SerializeField] private GameObject _mainMenu;
    [SerializeField] private Transform _playPosition;
    [SerializeField] private GameObject _settingsCanvas;

    [Header("Points Of Interest")]
    [SerializeField] private Transform _theater;
    [SerializeField] private Transform _book;

    [Header("Movement")]
    [SerializeField] private float _moveSpeed      = 1.5f;
    [SerializeField] private float _rotationSpeed  = 4f;
    
    [Header("Audio")]
    [SerializeField] private EventReference _introSongClip;
    [SerializeField] private float volume = 1f;

    [Header("Scene")]
#if UNITY_EDITOR
    [SerializeField] private SceneAsset _playScene;
#endif

    [SerializeField, HideInInspector] private string _playScenePath;

    private bool _isMoving;
    private Coroutine _moveCoroutine;
    
    private EventInstance _introSongInstance;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible   = true;

        if (_objectToMove == null && Camera.main != null)
            _objectToMove = Camera.main.transform;
        
        _introSongInstance = RuntimeManager.CreateInstance(_introSongClip);
        _introSongInstance.setVolume(volume);
        _introSongInstance.start();
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        if (_playScene != null)
            _playScenePath = AssetDatabase.GetAssetPath(_playScene);
    }
#endif

    private void OnDestroy()
    {
        _introSongInstance.stop(FMOD.Studio.STOP_MODE.IMMEDIATE);
        _introSongInstance.release();
    }

    public void PlayButton()
    {
        AudioManager.Instance?.PlayUIMenuConfirm();
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
        _introSongInstance.stop(FMOD.Studio.STOP_MODE.IMMEDIATE);
    }

    public void SettingsButton()
    {
        AudioManager.Instance?.PlayUIMenuConfirm();
        if (!_settingsCanvas.activeSelf) _settingsCanvas.SetActive(true);
        if (_mainMenu.activeSelf)        _settingsCanvas.SetActive(false);
    }

    public void BackButton()
    {
        AudioManager.Instance?.PlayUIMenuBack();
        if (_settingsCanvas.activeSelf)  _settingsCanvas.SetActive(false);
        if (!_mainMenu.activeSelf)       _settingsCanvas.SetActive(true);
    }

    public void ExitButton()
    {
        AudioManager.Instance?.PlayUIMenuConfirm();

#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#else
        Application.Quit();
#endif
    }

    private void MoveToPosition(Transform targetPosition, Transform lookTarget, System.Action onArrive)
    {
        if (_isMoving) return;

        if (_objectToMove == null)
        {
            return;
        }

        if (targetPosition == null)
        {
            return;
        }

        if (_moveCoroutine != null)
            StopCoroutine(_moveCoroutine);

        _moveCoroutine = StartCoroutine(MoveRoutine(targetPosition, lookTarget, onArrive));
    }

    private IEnumerator MoveRoutine(Transform targetPosition, Transform lookTarget, System.Action onArrive)
    {
        _isMoving = true;

        Vector3    startPosition = _objectToMove.position;
        Quaternion startRotation = _objectToMove.rotation;
        Vector3    finalPosition = targetPosition.position;
        Quaternion finalRotation = targetPosition.rotation;

        if (lookTarget != null)
        {
            Vector3 direction = lookTarget.position - finalPosition;
            if (direction != Vector3.zero)
                finalRotation = Quaternion.LookRotation(direction.normalized, Vector3.up);
        }

        float distance = Vector3.Distance(startPosition, finalPosition);
        float duration = Mathf.Max(distance / _moveSpeed, 0.01f);
        float timer    = 0f;

        while (timer < duration)
        {
            timer += Time.deltaTime;
            float t = Mathf.SmoothStep(0f, 1f, timer / duration);

            _objectToMove.position = Vector3.Lerp(startPosition, finalPosition, t);
            _objectToMove.rotation = Quaternion.Slerp(startRotation, finalRotation, t);

            yield return null;
        }

        _objectToMove.position = finalPosition;
        _objectToMove.rotation = finalRotation;

        _isMoving = false;
        onArrive?.Invoke();
    }

    private void LoadGame()
    {
        if (string.IsNullOrEmpty(_playScenePath))
        {
            return;
        }

        SceneManager.LoadScene(_playScenePath);
    }
}
