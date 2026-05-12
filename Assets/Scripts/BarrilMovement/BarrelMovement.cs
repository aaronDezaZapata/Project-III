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

    [Header("Shake Animation (Aviso)")]
    public float shakeMagnitude = 0.05f;
    public float shakeSpeed = 35f;

    private enum BarrelAnimState { Idle, PressDown, Recovering, Released }

    private Vector3 _startPos;
    private Quaternion _startRot;
    private float _randomOffset;
    private FallingPlatformController _platformController;

    private BarrelAnimState _animState = BarrelAnimState.Idle;
    private Vector3 _pressedPos;
    private Vector3 currentBasePos;

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
                if (_animState != BarrelAnimState.PressDown)
                {
                    _pressedPos = _startPos + Vector3.down * pressDownAmount;
                    currentBasePos = transform.position;
                    _animState = BarrelAnimState.PressDown;
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
        currentBasePos = Vector3.MoveTowards(
            currentBasePos,
            _pressedPos,
            pressDownSpeed * Time.deltaTime
        );

        float shakeX = Mathf.Sin(Time.time * shakeSpeed) * shakeMagnitude;
        float shakeZ = Mathf.Cos(Time.time * shakeSpeed * 0.8f) * shakeMagnitude;

        transform.position = currentBasePos + new Vector3(shakeX, 0f, shakeZ);
        transform.rotation = Quaternion.Slerp(transform.rotation, _startRot, pressDownSpeed * Time.deltaTime);
    }

    private void RecoverAnimation()
    {
        currentBasePos = Vector3.MoveTowards(
            currentBasePos,
            _startPos,
            recoverSpeed * Time.deltaTime
        );

        transform.position = currentBasePos;
        transform.rotation = Quaternion.Slerp(transform.rotation, _startRot, recoverSpeed * Time.deltaTime);

        if (Vector3.Distance(currentBasePos, _startPos) < 0.01f)
        {
            transform.position = _startPos;
            transform.rotation = _startRot;
            _animState = BarrelAnimState.Idle;
        }
    }
}
