using UnityEngine;

public class ForceReceiver : MonoBehaviour
{
    [SerializeField] private CharacterController _controller;
    [SerializeField] private float _drag = 0.4f;
    [SerializeField] private float _playerGravity;

    private Vector3 _dampingVelocity;
    private Vector3 _impact;
    private float _verticalVelocity;
    private bool _useGravity = true;

    public float VerticalVelocity => _verticalVelocity;
    public Vector3 Movement => _impact + Vector3.up * _verticalVelocity;

    private void Update()
    {
        bool actuallyGrounded = _controller.isGrounded && (_controller.collisionFlags & CollisionFlags.Below) != 0;

        if (_verticalVelocity < 0f && actuallyGrounded)
            _verticalVelocity = -2f;
        else
            _verticalVelocity += _playerGravity * Time.deltaTime;

        _impact = Vector3.SmoothDamp(_impact, Vector3.zero, ref _dampingVelocity, _drag);
    }

    public void Jump(float jumpForce)
    {
        _verticalVelocity = jumpForce;
    }

    public void ResetVerticalVelocity()
    {
        if (_verticalVelocity > 0f)
            _verticalVelocity = 0f;
    }

    public void AddForce(Vector3 force)
    {
        _impact += force;
    }

    public void SetUseGravity(bool value)
    {
        _useGravity = value;

        if (!value)
            _verticalVelocity = 0f;
    }

    public void ForceMovement()
    {
        _controller.Move(Movement * Time.deltaTime);
    }

    public void Reset()
    {
        _impact = Vector3.zero;
        _verticalVelocity = 0f;
    }
}
