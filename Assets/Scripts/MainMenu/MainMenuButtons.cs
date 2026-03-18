using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Splines;

public class MainMenuButtons : MonoBehaviour
{
    [Header("Spline")]
    public SplineAnimate splineAnimate;
    public SplineContainer splineContainer;

    [Header("Points Of Interest")]
    [SerializeField] Transform theater;
    [SerializeField] Transform book;

    [Header("Menu Nodes")]
    public const int menuNode = 0;
    public const int playNode = 3;
    public const int settingsNode = 2;

    [Header("Movement")]
    public float moveSpeed = 1.5f;
    public float rotationSpeed = 4f;

    [Header("Scene")]
    public string playSceneName = "PlayGround";

    bool isMoving;
    Transform currentLookTarget;

    float GetNodeTime(int nodeIndex)
    {
        int count = splineContainer.Spline.Count;
        return (float)nodeIndex / (count - 1);
    }

    void Start()
    {
        splineAnimate.NormalizedTime = GetNodeTime(menuNode);
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
    }

    void Update()
    {
        if (currentLookTarget != null)
        {
            Vector3 dir = currentLookTarget.position - splineAnimate.transform.position;
            Quaternion targetRot = Quaternion.LookRotation(dir);

            splineAnimate.transform.rotation = Quaternion.Slerp(
                splineAnimate.transform.rotation,
                targetRot,
                Time.deltaTime * rotationSpeed
            );
        }
    }

    public void PlayButton()
    {
        MoveToNode(playNode, book, LoadGame);
    }

    public void SettingsButton()
    {
        MoveToNode(settingsNode, theater, null);
    }

    public void BackButton()
    {
        MoveToNode(menuNode, null, null);
    }

    public void ExitButton()
    {
        Application.Quit();
    }

    void MoveToNode(int nodeIndex, Transform lookTarget, System.Action onArrive)
    {
        if (isMoving) return;

        currentLookTarget = lookTarget;

        float targetTime = GetNodeTime(nodeIndex);
        StartCoroutine(MoveSpline(targetTime, onArrive));
    }

    IEnumerator MoveSpline(float target, System.Action onArrive)
    {
        isMoving = true;

        float start = splineAnimate.NormalizedTime;
        float t = 0;

        while (t < 1)
        {
            t += Time.deltaTime * moveSpeed;

            splineAnimate.NormalizedTime = Mathf.Lerp(start, target, t);

            yield return null;
        }

        splineAnimate.NormalizedTime = target;

        onArrive?.Invoke();

        isMoving = false;
    }

    void LoadGame()
    {
        SceneManager.LoadScene(1);
    }
}