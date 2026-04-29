using System;
using UnityEngine;
using Random = UnityEngine.Random;

public class BarrelMovement : MonoBehaviour
{
    [Header("Movimiento vertical")]
    public float floatSpeed = 1f;
    public float floatHeight = 0.2f;
    public float driftAmount = 0.1f;
    public float driftSpeed = 0.5f;

    [Header("Balanceo")]
    public float tiltSpeed = 1.2f;
    public float tiltAmountX = 5f;
    public float tiltAmountZ = 5f;

    [Header("Press Down Animation")]
    public float pressDownAmount = 0.15f;
    public float pressDownSpeed = 3f;
    public float recoverSpeed = 2f;

    private enum BarrelAnimState { Idle, PressDown, Recovering, Released }

    private Vector3 _startPos;
    private Quaternion _startRot;
    private float _randomOffset;
    private FallingPlatformController _platformController;

    private BarrelAnimState _animState = BarrelAnimState.Idle;
    private Vector3 _pressedPos;

    private void Awake()
    {
        _platformController = GetComponent<FallingPlatformController>();
    }

    private void Start()
    {
        _startPos = transform.position;
        _startRot = transform.rotation;
        _randomOffset = Random.Range(0f, 100f);
    }

    private void Update()
    {
        switch (_platformController.CurrentState)
        {
            case PlatformState.Countdown:
                _pressedPos = _startPos + Vector3.down * pressDownAmount;
                _animState = BarrelAnimState.PressDown;
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
                    _startPos = transform.position;
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
            case BarrelAnimState.Released:
                break;
        }
    }

    private void IdleMovementAnimation()
    {
        float t = Time.time + _randomOffset;

        float xOffset = Mathf.Sin(t * driftSpeed) * driftAmount;
        float yOffset = Mathf.Sin(t * floatSpeed) * floatHeight;
        float zOffset = Mathf.Sin(t * driftSpeed * 0.7f) * driftAmount;

        transform.position = new Vector3(
            _startPos.x + xOffset,
            _startPos.y + yOffset,
            _startPos.z + zOffset
        );

        float rotX = Mathf.Sin(Time.time * tiltSpeed) * tiltAmountX;
        float rotZ = Mathf.Cos(Time.time * tiltSpeed * 0.8f) * tiltAmountZ;

        transform.rotation = _startRot * Quaternion.Euler(rotX, 0f, rotZ);
    }

    private void PressDownAnimation()
    {
        transform.position = Vector3.MoveTowards(
            transform.position,
            _pressedPos,
            pressDownSpeed * Time.deltaTime
        );
        transform.rotation = Quaternion.Slerp(transform.rotation, _startRot, pressDownSpeed * Time.deltaTime);
    }

    private void RecoverAnimation()
    {
        transform.position = Vector3.MoveTowards(
            transform.position,
            _startPos,
            recoverSpeed * Time.deltaTime
        );

        transform.rotation = Quaternion.Slerp(transform.rotation, _startRot, recoverSpeed * Time.deltaTime);

        if (Vector3.Distance(transform.position, _startPos) < 0.01f)
        {
            transform.position = _startPos;
            transform.rotation = _startRot;
            _animState = BarrelAnimState.Idle;
        }
    }
}
