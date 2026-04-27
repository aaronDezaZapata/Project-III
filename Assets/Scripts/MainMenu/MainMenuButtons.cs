using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class MainMenuButtons : MonoBehaviour
{
    [Header("Camera / Object To Move")]
    [SerializeField] private Transform objectToMove;

    [Header("Menu Positions")]
    [SerializeField] private Transform menuPosition;
    [SerializeField] private Transform playPosition;
    [SerializeField] private Transform settingsPosition;

    [Header("Points Of Interest")]
    [SerializeField] private Transform theater;
    [SerializeField] private Transform book;

    [Header("Movement")]
    [SerializeField] private float moveSpeed = 1.5f;
    [SerializeField] private float rotationSpeed = 4f;

    [Header("Scene")]
#if UNITY_EDITOR
    [SerializeField] private SceneAsset playScene;
#endif

    [SerializeField, HideInInspector] private string playScenePath;

    private bool isMoving;
    private Coroutine moveCoroutine;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;

        if (objectToMove == null && Camera.main != null)
            objectToMove = Camera.main.transform;
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        if (playScene != null)
        {
            playScenePath = AssetDatabase.GetAssetPath(playScene);
        }
    }
#endif

    public void PlayButton()
    {
        AudioManager.Instance?.PlayUIMenuConfirm();
        MoveToPosition(playPosition, book, LoadGame);
    }

    public void SettingsButton()
    {
        AudioManager.Instance?.PlayUIMenuConfirm();
        MoveToPosition(settingsPosition, theater, null);
    }

    public void BackButton()
    {
        AudioManager.Instance?.PlayUIMenuBack();
        MoveToPosition(menuPosition, null, null);
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
        if (isMoving) return;

        if (objectToMove == null)
        {
            Debug.LogError("No hay objectToMove asignado en MainMenuButtons.");
            return;
        }

        if (targetPosition == null)
        {
            Debug.LogError("No hay targetPosition asignado en MainMenuButtons.");
            return;
        }

        if (moveCoroutine != null)
            StopCoroutine(moveCoroutine);

        moveCoroutine = StartCoroutine(MoveRoutine(targetPosition, lookTarget, onArrive));
    }

    private IEnumerator MoveRoutine(Transform targetPosition, Transform lookTarget, System.Action onArrive)
    {
        isMoving = true;

        Vector3 startPosition = objectToMove.position;
        Quaternion startRotation = objectToMove.rotation;

        Vector3 finalPosition = targetPosition.position;
        Quaternion finalRotation = targetPosition.rotation;

        if (lookTarget != null)
        {
            Vector3 direction = lookTarget.position - finalPosition;

            if (direction != Vector3.zero)
                finalRotation = Quaternion.LookRotation(direction.normalized, Vector3.up);
        }

        float distance = Vector3.Distance(startPosition, finalPosition);
        float duration = distance / moveSpeed;

        if (duration <= 0.01f)
            duration = 0.01f;

        float timer = 0f;

        while (timer < duration)
        {
            timer += Time.deltaTime;

            float t = timer / duration;
            t = Mathf.SmoothStep(0f, 1f, t);

            objectToMove.position = Vector3.Lerp(startPosition, finalPosition, t);
            objectToMove.rotation = Quaternion.Slerp(startRotation, finalRotation, t);

            yield return null;
        }

        objectToMove.position = finalPosition;
        objectToMove.rotation = finalRotation;

        isMoving = false;

        onArrive?.Invoke();
    }

    private void LoadGame()
    {
        if (string.IsNullOrEmpty(playScenePath))
        {
            Debug.LogError("No hay escena asignada en MainMenuButtons.");
            return;
        }

        SceneManager.LoadScene(playScenePath);
    }
}