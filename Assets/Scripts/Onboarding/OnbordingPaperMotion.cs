using UnityEngine;

public class OnboardingPaperMotion : MonoBehaviour
{
    public enum MotionType
    {
        Jump,
        DoubleJump,
        Walk,
        HeiserFloat,
        Whip,
        PaintBounce,
        PullPopup
    }

    [Header("General")]
    [SerializeField] private MotionType _motionType = MotionType.Jump;
    [SerializeField] private bool  _playOnEnable = true;
    [SerializeField] private bool  _loop         = true;
    [SerializeField] private float _speed        = 1f;
    [SerializeField] private float _loopDelay    = 0.2f;

    [Header("Movement Amounts")]
    [SerializeField] private float _horizontalDistance = 1f;
    [SerializeField] private float _verticalDistance   = 1f;
    [SerializeField] private float _bounceStrength     = 0.25f;
    [SerializeField] private float _sineAmplitude      = 0.25f;
    [SerializeField] private float _sineFrequency      = 2f;

    [Header("Pull Popup")]
    [SerializeField] private float _pullDistance        = 1f;
    [SerializeField] private float _pullShakeStrength   = 0.08f;
    [SerializeField] private float _pullShakeFrequency  = 20f;

    [Header("Optional Rotation")]
    [SerializeField] private bool  _useRotation    = false;
    [SerializeField] private Vector3 _rotationAxis = new Vector3(0f, 0f, 1f);
    [SerializeField] private float _rotationAmount = 10f;

    [Header("Whip Pendulum")]
    [SerializeField] private float _swingAngle = 120f;
    [SerializeField] private Transform _flipTarget;

    [Header("Auto Flip")]
    [SerializeField] private bool  _useAutoFlip      = true;
    [SerializeField] private float _flipEverySeconds = 2f;
    [SerializeField] private bool  _startFacingRight = true;

    private Vector3    _startPos;
    private Quaternion _startRot;
    private Vector3    _startScale;

    private float _timer;
    private bool  _isPlaying;
    private bool  _waitingLoop;
    private float _loopWaitTimer;

    private float _flipTimer;
    private bool  _isFacingRight;

    private Vector3 _currentAnchorPos;
    private bool    _walkForward = true;

    private void Awake()
    {
        _startPos   = transform.localPosition;
        _startRot   = transform.localRotation;
        _startScale = transform.localScale;

        _currentAnchorPos = _startPos;
    }

    private void OnEnable()
    {
        _isFacingRight = _startFacingRight;
        ApplyFacingDirection();

        if (_playOnEnable)
            Play();
        else
            ResetTransform();
    }

    public void Play()
    {
        _timer         = 0f;
        _isPlaying     = true;
        _waitingLoop   = false;
        _loopWaitTimer = 0f;
        _flipTimer     = 0f;

        _isFacingRight    = _startFacingRight;
        _walkForward      = true;
        _currentAnchorPos = _startPos;

        ResetTransform();
        ApplyFacingDirection();
    }

    public void Stop()
    {
        _isPlaying   = false;
        _waitingLoop = false;
        ResetTransform();
    }

    public void ResetTransform()
    {
        transform.localPosition = _currentAnchorPos;
        transform.localRotation = _startRot;
        ApplyFacingDirection();
    }

    private void Update()
    {
        HandleAutoFlip();

        if (!_isPlaying) return;

        if (_waitingLoop)
        {
            _loopWaitTimer += Time.deltaTime;
            if (_loopWaitTimer >= _loopDelay)
            {
                _waitingLoop   = false;
                _timer         = 0f;
            }
            return;
        }

        _timer += Time.deltaTime * _speed;

        bool finished = false;

        switch (_motionType)
        {
            case MotionType.Jump:        finished = AnimateJump();        break;
            case MotionType.DoubleJump:  finished = AnimateDoubleJump();  break;
            case MotionType.Walk:        finished = AnimateWalk();        break;
            case MotionType.HeiserFloat: finished = AnimateHeiserFloat(); break;
            case MotionType.Whip:        finished = AnimateWhip();        break;
            case MotionType.PaintBounce: finished = AnimatePaintBounce(); break;
            case MotionType.PullPopup:   finished = AnimatePullPopup();   break;
        }

        if (!finished) return;

        if (_motionType == MotionType.Walk      ||
            _motionType == MotionType.Jump      ||
            _motionType == MotionType.DoubleJump)
            return;

        if (_loop)
        {
            _waitingLoop   = true;
            _loopWaitTimer = 0f;
            ResetTransform();
        }
        else
        {
            _isPlaying = false;
        }
    }

    private void HandleAutoFlip()
    {
        if (!_useAutoFlip || _flipEverySeconds <= 0f) return;

        _flipTimer += Time.deltaTime;

        if (_flipTimer >= _flipEverySeconds)
        {
            _flipTimer     = 0f;
            _isFacingRight = !_isFacingRight;
            ApplyFacingDirection();
        }
    }

    private void ApplyFacingDirection()
    {
        Vector3 newScale = _startScale;
        newScale.x = Mathf.Abs(_startScale.x) * (_isFacingRight ? 1f : -1f);
        transform.localScale = newScale;
    }

    private bool AnimateJump()
    {
        float t        = Mathf.Clamp01(_timer / 1f);
        float targetX  = _walkForward ? _horizontalDistance : -_horizontalDistance;
        float x        = Mathf.Lerp(0f, targetX, t);
        float y        = 4f * _verticalDistance * t * (1f - t);
        float rot      = Mathf.Sin(t * Mathf.PI) * _rotationAmount;

        ApplyTransform(new Vector3(x, y, 0f), rot);

        if (t >= 1f)
        {
            _currentAnchorPos += new Vector3(targetX, 0f, 0f);
            _walkForward       = !_walkForward;
            _isFacingRight     = _walkForward;
            ApplyFacingDirection();
            _timer = 0f;
        }

        return false;
    }

    private bool AnimateDoubleJump()
    {
        float duration = 1.4f;
        float t        = Mathf.Clamp01(_timer / duration);
        float targetX  = _walkForward ? _horizontalDistance : -_horizontalDistance;
        float x        = Mathf.Lerp(0f, targetX, t);

        float y;
        if (t < 0.5f)
        {
            float localT = t / 0.5f;
            y = 4f * _verticalDistance * localT * (1f - localT);
        }
        else
        {
            float localT = (t - 0.5f) / 0.5f;
            y = 4f * _verticalDistance * 0.85f * localT * (1f - localT) + _verticalDistance * 0.2f;
        }

        float rot = Mathf.Sin(t * Mathf.PI * 2f) * _rotationAmount;
        ApplyTransform(new Vector3(x, y, 0f), rot);

        if (t >= 1f)
        {
            _currentAnchorPos += new Vector3(targetX, 0f, 0f);
            _walkForward       = !_walkForward;
            _isFacingRight     = _walkForward;
            ApplyFacingDirection();
            _timer = 0f;
        }

        return false;
    }

    private bool AnimateWalk()
    {
        float t       = Mathf.Clamp01(_timer / 1f);
        float targetX = _walkForward ? _horizontalDistance : -_horizontalDistance;
        float x       = Mathf.Lerp(0f, targetX, t);
        float y       = Mathf.Sin(t * Mathf.PI * 2f) * 0.03f;
        float rot     = Mathf.Sin(t * Mathf.PI * 2f) * _rotationAmount * 0.2f;

        ApplyTransform(new Vector3(x, y, 0f), rot);

        if (t >= 1f)
        {
            _currentAnchorPos += new Vector3(targetX, 0f, 0f);
            _walkForward       = !_walkForward;
            _isFacingRight     = _walkForward;
            ApplyFacingDirection();
            _timer = 0f;
        }

        return false;
    }

    private bool AnimateHeiserFloat()
    {
        float y   = Mathf.Sin(_timer * _sineFrequency) * _sineAmplitude;
        float rot = Mathf.Sin(_timer * _sineFrequency) * _rotationAmount * 0.5f;

        ApplyTransform(new Vector3(0f, _verticalDistance + y, 0f), rot);
        return false;
    }

    private bool AnimateWhip()
    {
        float prevDeriv = Mathf.Cos((_timer - Time.deltaTime * _speed) * _sineFrequency);
        float currDeriv = Mathf.Cos(_timer * _sineFrequency);
        if (prevDeriv * currDeriv < 0f)
        {
            _isFacingRight = !_isFacingRight;
            ApplyFacingDirection();
        }

        float t = (Mathf.Sin(_timer * _sineFrequency) + 1f) * 0.5f;
        float angle = Mathf.Lerp(0f, _swingAngle, t);

        transform.localRotation = _startRot * Quaternion.AngleAxis(angle, Vector3.forward);
        transform.localPosition = _currentAnchorPos;
        return false;
    }

    private bool AnimatePaintBounce()
    {
        float duration = 0.45f;
        float t        = Mathf.Clamp01(_timer / duration);
        float y        = Mathf.Sin(t * Mathf.PI) * _bounceStrength;

        ApplyTransform(new Vector3(0f, y, 0f), Mathf.Sin(t * Mathf.PI) * _rotationAmount * 0.4f);
        return t >= 1f;
    }

    private bool AnimatePullPopup()
    {
        float t         = Mathf.Clamp01(_timer / 1f);
        float direction = _isFacingRight ? 1f : -1f;
        float x         = Mathf.Lerp(0f, _pullDistance * direction, t);
        float shakeY    = Mathf.Sin(t * _pullShakeFrequency) * _pullShakeStrength * (1f - t);
        float shakeRot  = Mathf.Sin(t * _pullShakeFrequency * 0.75f) * _rotationAmount * 0.5f * (1f - t);

        ApplyTransform(new Vector3(x, shakeY, 0f), shakeRot);
        return t >= 1f;
    }

    private void ApplyTransform(Vector3 localOffset, float rotAmount)
    {
        transform.localPosition = _currentAnchorPos + localOffset;

        transform.localRotation = _useRotation
            ? _startRot * Quaternion.AngleAxis(rotAmount, _rotationAxis.normalized)
            : _startRot;

        ApplyFacingDirection();
    }
}
