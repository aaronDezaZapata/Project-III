using UnityEngine;

public class OnboardingPaperMotion : MonoBehaviour
{
    public enum MotionType
    {
        Jump,
        DoubleJump,
        Walk,
        HeiserFloat,
        Liana,
        PaintBounce,
        PullPopup
    }

    [Header("General")]
    [SerializeField] private MotionType motionType = MotionType.Jump;
    [SerializeField] private bool playOnEnable = true;
    [SerializeField] private bool loop = true;
    [SerializeField] private float speed = 1f;
    [SerializeField] private float loopDelay = 0.2f;

    [Header("Movement Amounts")]
    [SerializeField] private float horizontalDistance = 1f;
    [SerializeField] private float verticalDistance = 1f;
    [SerializeField] private float bounceStrength = 0.25f;
    [SerializeField] private float sineAmplitude = 0.25f;
    [SerializeField] private float sineFrequency = 2f;

    [Header("Pull Popup")]
    [SerializeField] private float pullDistance = 1f;
    [SerializeField] private float pullShakeStrength = 0.08f;
    [SerializeField] private float pullShakeFrequency = 20f;

    [Header("Optional Rotation")]
    [SerializeField] private bool useRotation = false;
    [SerializeField] private Vector3 rotationAxis = new Vector3(0f, 0f, 1f);
    [SerializeField] private float rotationAmount = 10f;

    [Header("Auto Flip")]
    [SerializeField] private bool useAutoFlip = true;
    [SerializeField] private float flipEverySeconds = 2f;
    [SerializeField] private bool startFacingRight = true;

    private Vector3 startPos;
    private Quaternion startRot;
    private Vector3 startScale;

    private float timer;
    private bool isPlaying;
    private bool waitingLoop;
    private float loopWaitTimer;

    private float flipTimer;
    private bool isFacingRight;

    private Vector3 currentAnchorPos;
    private bool walkForward = true;

    private void Awake()
    {
        startPos = transform.localPosition;
        startRot = transform.localRotation;
        startScale = transform.localScale;

        currentAnchorPos = startPos;
    }

    private void OnEnable()
    {
        isFacingRight = startFacingRight;
        ApplyFacingDirection();

        if (playOnEnable)
        {
            Play();
        }
        else
        {
            ResetTransform();
        }
    }

    public void Play()
    {
        timer = 0f;
        isPlaying = true;
        waitingLoop = false;
        loopWaitTimer = 0f;
        flipTimer = 0f;

        isFacingRight = startFacingRight;
        walkForward = true;
        currentAnchorPos = startPos;

        ResetTransform();
        ApplyFacingDirection();
    }

    public void Stop()
    {
        isPlaying = false;
        waitingLoop = false;
        ResetTransform();
    }

    public void ResetTransform()
    {
        transform.localPosition = currentAnchorPos;
        transform.localRotation = startRot;
        ApplyFacingDirection();
    }

    private void Update()
    {
        HandleAutoFlip();

        if (!isPlaying)
            return;

        if (waitingLoop)
        {
            loopWaitTimer += Time.deltaTime;
            if (loopWaitTimer >= loopDelay)
            {
                waitingLoop = false;
                timer = 0f;
            }
            return;
        }

        timer += Time.deltaTime * speed;

        bool finished = false;

        switch (motionType)
        {
            case MotionType.Jump:
                finished = AnimateJump();
                break;

            case MotionType.DoubleJump:
                finished = AnimateDoubleJump();
                break;

            case MotionType.Walk:
                finished = AnimateWalk();
                break;

            case MotionType.HeiserFloat:
                finished = AnimateHeiserFloat();
                break;

            case MotionType.Liana:
                finished = AnimateLiana();
                break;

            case MotionType.PaintBounce:
                finished = AnimatePaintBounce();
                break;

            case MotionType.PullPopup:
                finished = AnimatePullPopup();
                break;
        }

        if (finished)
        {
            if (motionType == MotionType.Walk)
                return;

            if (loop)
            {
                waitingLoop = true;
                loopWaitTimer = 0f;
                ResetTransform();
            }
            else
            {
                isPlaying = false;
            }
        }
    }

    private void HandleAutoFlip()
    {
        if (!useAutoFlip || flipEverySeconds <= 0f)
            return;

        flipTimer += Time.deltaTime;

        if (flipTimer >= flipEverySeconds)
        {
            flipTimer = 0f;
            isFacingRight = !isFacingRight;
            ApplyFacingDirection();
        }
    }

    private void ApplyFacingDirection()
    {
        Vector3 newScale = startScale;
        newScale.x = Mathf.Abs(startScale.x) * (isFacingRight ? 1f : -1f);
        transform.localScale = newScale;
    }

    private bool AnimateJump()
    {
        float duration = 1f;
        float t = Mathf.Clamp01(timer / duration);

        float direction = isFacingRight ? 1f : -1f;

        float x = Mathf.Lerp(0f, horizontalDistance * direction, t);
        float y = 4f * verticalDistance * t * (1f - t);

        ApplyTransform(new Vector3(x, y, 0f), Mathf.Sin(t * Mathf.PI) * rotationAmount);

        return t >= 1f;
    }

    private bool AnimateDoubleJump()
    {
        float duration = 1.4f;
        float t = Mathf.Clamp01(timer / duration);

        float direction = isFacingRight ? 1f : -1f;

        float x = Mathf.Lerp(0f, horizontalDistance * direction, t);
        float y = 0f;

        if (t < 0.5f)
        {
            float localT = t / 0.5f;
            y = 4f * verticalDistance * localT * (1f - localT);
        }
        else
        {
            float localT = (t - 0.5f) / 0.5f;
            y = 4f * verticalDistance * 0.85f * localT * (1f - localT) + verticalDistance * 0.2f;
        }

        ApplyTransform(new Vector3(x, y, 0f), Mathf.Sin(t * Mathf.PI * 2f) * rotationAmount);

        return t >= 1f;
    }

    private bool AnimateWalk()
    {
        float duration = 1f;
        float t = Mathf.Clamp01(timer / duration);

        float targetX = walkForward ? horizontalDistance : -horizontalDistance;

        float x = Mathf.Lerp(0f, targetX, t);
        float y = Mathf.Sin(t * Mathf.PI * 2f) * 0.03f;

        float rot = Mathf.Sin(t * Mathf.PI * 2f) * rotationAmount * 0.2f;
        ApplyTransform(new Vector3(x, y, 0f), rot);

        if (t >= 1f)
        {
            currentAnchorPos += new Vector3(targetX, 0f, 0f);

            walkForward = !walkForward;
            isFacingRight = walkForward;
            ApplyFacingDirection();

            timer = 0f;
        }

        return false;
    }

    private bool AnimateHeiserFloat()
    {
        float y = Mathf.Sin(timer * sineFrequency) * sineAmplitude;
        float rot = Mathf.Sin(timer * sineFrequency) * rotationAmount * 0.5f;

        ApplyTransform(new Vector3(0f, verticalDistance + y, 0f), rot);

        return false;
    }

    private bool AnimateLiana()
    {
        float duration = 0.55f;
        float t = Mathf.Clamp01(timer / duration);

        float direction = isFacingRight ? 1f : -1f;

        float x = Mathf.Lerp(0f, horizontalDistance * direction, t);
        float y = Mathf.Sin(t * Mathf.PI) * sineAmplitude;

        ApplyTransform(new Vector3(x, y, 0f), Mathf.Sin(t * Mathf.PI) * rotationAmount);

        return t >= 1f;
    }

    private bool AnimatePaintBounce()
    {
        float duration = 0.45f;
        float t = Mathf.Clamp01(timer / duration);

        float y = Mathf.Sin(t * Mathf.PI) * bounceStrength;

        ApplyTransform(new Vector3(0f, y, 0f), Mathf.Sin(t * Mathf.PI) * rotationAmount * 0.4f);

        return t >= 1f;
    }

    private bool AnimatePullPopup()
    {
        float duration = 1f;
        float t = Mathf.Clamp01(timer / duration);

        float direction = isFacingRight ? 1f : -1f;

        float x = Mathf.Lerp(0f, pullDistance * direction, t);
        float shakeY = Mathf.Sin(t * pullShakeFrequency) * pullShakeStrength * (1f - t);
        float shakeRot = Mathf.Sin(t * pullShakeFrequency * 0.75f) * rotationAmount * 0.5f * (1f - t);

        ApplyTransform(new Vector3(x, shakeY, 0f), shakeRot);

        return t >= 1f;
    }

    private void ApplyTransform(Vector3 localOffset, float rotAmount)
    {
        transform.localPosition = currentAnchorPos + localOffset;

        if (useRotation)
        {
            transform.localRotation = startRot * Quaternion.AngleAxis(rotAmount, rotationAxis.normalized);
        }
        else
        {
            transform.localRotation = startRot;
        }

        ApplyFacingDirection();
    }
}