using UnityEngine;
using Random = UnityEngine.Random;

public class BarrelMovement : MonoBehaviour
{
    [Header("Vertical Movement")]
    [SerializeField] private float _floatSpeed  = 1f;
    [SerializeField] private float _floatHeight = 0.2f;
    [SerializeField] private float _driftAmount = 0.1f;
    [SerializeField] private float _driftSpeed  = 0.5f;

    [Header("Tilt")]
    [SerializeField] private float _tiltSpeed   = 1.2f;
    [SerializeField] private float _tiltAmountX = 5f;
    [SerializeField] private float _tiltAmountZ = 5f;

    [Header("Press Down Animation")]
    [SerializeField] private float _pressDownAmount = 0.15f;
    [SerializeField] private float _pressDownSpeed  = 3f;
    [SerializeField] private float _recoverSpeed    = 2f;

    [Header("Shake Animation")]
    [SerializeField] private float _shakeMagnitude = 0.05f;
    [SerializeField] private float _shakeSpeed     = 35f;

    private enum BarrelAnimState { Idle, PressDown, Recovering, Released }

    private Vector3 _startPos;
    private Quaternion _startRot;
    private float _randomOffset;
    private FallingPlatformController _platformController;

    private BarrelAnimState _animState = BarrelAnimState.Idle;
    private Vector3 _pressedPos;
    private Vector3 _currentBasePos;

    private void Awake()
    {
        _platformController = GetComponent<FallingPlatformController>();
    }

    private void Start()
    {
        _startPos      = transform.position;
        _startRot      = transform.rotation;
        _randomOffset  = Random.Range(0f, 100f);
    }

    private void Update()
    {
        switch (_platformController.CurrentState)
        {
            case PlatformState.Countdown:
                if (_animState != BarrelAnimState.PressDown)
                {
                    _pressedPos    = _startPos + Vector3.down * _pressDownAmount;
                    _currentBasePos = transform.position;
                    _animState     = BarrelAnimState.PressDown;
                }
                break;

            case PlatformState.Falling:
            case PlatformState.WaitingToRespawn:
            case PlatformState.Rising:
                _animState = BarrelAnimState.Released;
                break;

            case PlatformState.Idle:
                if (_animState == BarrelAnimState.PressDown)
                    _animState = BarrelAnimState.Recovering;
                else if (_animState == BarrelAnimState.Released)
                {
                    _startPos  = transform.position;
                    _animState = BarrelAnimState.Idle;
                }
                break;
        }

        switch (_animState)
        {
            case BarrelAnimState.Idle:
                IdleMovementAnimation();
                break;
            case BarrelAnimState.PressDown:
                PressDownAnimation();
                break;
            case BarrelAnimState.Recovering:
                RecoverAnimation();
                break;
        }
    }

    private void IdleMovementAnimation()
    {
        float t = Time.time + _randomOffset;

        float xOffset = Mathf.Sin(t * _driftSpeed) * _driftAmount;
        float yOffset = Mathf.Sin(t * _floatSpeed) * _floatHeight;
        float zOffset = Mathf.Sin(t * _driftSpeed * 0.7f) * _driftAmount;

        transform.position = new Vector3(
            _startPos.x + xOffset,
            _startPos.y + yOffset,
            _startPos.z + zOffset
        );

        float rotX = Mathf.Sin(Time.time * _tiltSpeed) * _tiltAmountX;
        float rotZ = Mathf.Cos(Time.time * _tiltSpeed * 0.8f) * _tiltAmountZ;

        transform.rotation = _startRot * Quaternion.Euler(rotX, 0f, rotZ);
    }

    private void PressDownAnimation()
    {
        _currentBasePos = Vector3.MoveTowards(
            _currentBasePos,
            _pressedPos,
            _pressDownSpeed * Time.deltaTime
        );

        float shakeX = Mathf.Sin(Time.time * _shakeSpeed) * _shakeMagnitude;
        float shakeZ = Mathf.Cos(Time.time * _shakeSpeed * 0.8f) * _shakeMagnitude;

        transform.position = _currentBasePos + new Vector3(shakeX, 0f, shakeZ);
        transform.rotation = Quaternion.Slerp(transform.rotation, _startRot, _pressDownSpeed * Time.deltaTime);
    }

    private void RecoverAnimation()
    {
        _currentBasePos = Vector3.MoveTowards(
            _currentBasePos,
            _startPos,
            _recoverSpeed * Time.deltaTime
        );

        transform.position = _currentBasePos;
        transform.rotation = Quaternion.Slerp(transform.rotation, _startRot, _recoverSpeed * Time.deltaTime);

        if (Vector3.Distance(_currentBasePos, _startPos) < 0.01f)
        {
            transform.position = _startPos;
            transform.rotation = _startRot;
            _animState         = BarrelAnimState.Idle;
        }
    }
}
