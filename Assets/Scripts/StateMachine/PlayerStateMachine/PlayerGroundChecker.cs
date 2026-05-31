using UnityEngine;

public class PlayerGroundChecker : MonoBehaviour
{
    private PlayerStateMachine _player;

    private int _footstepIndex;
    private float _lastAirVerticalVelocity;
    private bool _hasBeenAirborne;

    private void Awake()
    {
        _player = GetComponent<PlayerStateMachine>();
    }

    public void CheckGrounded()
    {
        bool wasGroundedBefore = _player.isGrounded;

        bool hitGround = Physics.SphereCast(
            _player.groundCheckOrigin.position,
            _player.groundCheckRadius,
            Vector3.down,
            out RaycastHit hit,
            _player.groundCheckDistance,
            _player.groundMask
        );

        if (hitGround)
        {
            float angle = Vector3.Angle(Vector3.up, hit.normal);
            _player.isGrounded = angle <= _player.Controller.slopeLimit;
        }
        else
        {
            _player.isGrounded = false;
        }

        if (!_player.isGrounded)
        {
            _hasBeenAirborne = true;

            float controllerY = _player.Controller != null ? _player.Controller.velocity.y : 0f;
            float forceReceiverY = _player.ForceReceiver != null ? _player.ForceReceiver.VerticalVelocity : 0f;

            _lastAirVerticalVelocity = Mathf.Min(controllerY, forceReceiverY);
        }

        if (!wasGroundedBefore && _player.isGrounded && _hasBeenAirborne)
        {
            float fallSpeed = Mathf.Abs(_lastAirVerticalVelocity);

            if (fallSpeed >= _player.MinFallVelocityToPlayLandingParticle)
            {
                if (_player.LandingParticles != null)
                    _player.LandingParticles.Play();
            }

            if (fallSpeed >= 8f)
                _player.PlayerAudio?.PlayHeavyImpact();
            else if (fallSpeed >= 1.5f)
                _player.PlayerAudio?.PlayLanding();

            _hasBeenAirborne = false;
            _lastAirVerticalVelocity = 0f;
        }

        if (_player.isGrounded)
        {
            _player.isGeyserOnCooldown = false;
            _player.geyserCooldownTimer = 0f;
            _player.isOnSteepSlope = false;
        }
    }

    public void ApplySlopeSlide()
    {
        bool hitGround = Physics.SphereCast(
            _player.groundCheckOrigin.position,
            _player.groundCheckRadius,
            Vector3.down,
            out RaycastHit hit,
            _player.groundCheckDistance,
            _player.groundMask
        );

        if (!hitGround) return;

        float angle = Vector3.Angle(Vector3.up, hit.normal);
        if (angle <= _player.Controller.slopeLimit) return;

        _player.isOnSteepSlope = true;

        Vector3 slideDir = Vector3.ProjectOnPlane(Vector3.down, hit.normal).normalized;
        _player.ForceReceiver.AddForce(slideDir * _player.slopeSlideSpeed * Time.deltaTime);
    }

    public void PlayFootstepParticle()
    {
        if (!_player.isGrounded)
            return;

        if (_footstepIndex == 0)
        {
            if (_player.FootstepParticles1 != null) _player.FootstepParticles1.Play();
            _footstepIndex = 1;
        }
        else
        {
            if (_player.FootstepParticles2 != null) _player.FootstepParticles2.Play();
            _footstepIndex = 0;
        }

        FootstepSurfaceType surfaceType = DetectFootstepSurface();
        FootstepSpeedType speedType = DetectFootstepSpeed();

        _player.PlayerAudio?.PlayFootstep(surfaceType, speedType);
    }

    private FootstepSpeedType DetectFootstepSpeed()
    {
        Vector3 horizontalVelocity = new Vector3(
            _player.Controller.velocity.x,
            0f,
            _player.Controller.velocity.z
        );

        float speed = horizontalVelocity.magnitude;

        return speed >= 4.5f ? FootstepSpeedType.Run : FootstepSpeedType.Walk;
    }

    private FootstepSurfaceType DetectFootstepSurface()
    {
        if (_player.groundCheckOrigin == null)
            return FootstepSurfaceType.Ink;

        bool hitGround = Physics.SphereCast(
            _player.groundCheckOrigin.position,
            _player.groundCheckRadius,
            Vector3.down,
            out RaycastHit hit,
            _player.groundCheckDistance + 0.3f,
            _player.groundMask
        );

        if (!hitGround)
            return FootstepSurfaceType.Ink;

        int layer = hit.collider.gameObject.layer;

        if (layer == LayerMask.NameToLayer("Ink")) return FootstepSurfaceType.Ink;
        if (layer == LayerMask.NameToLayer("Leaves")) return FootstepSurfaceType.Leaves;
        if (layer == LayerMask.NameToLayer("Rock")) return FootstepSurfaceType.Rock;
        if (layer == LayerMask.NameToLayer("Sand")) return FootstepSurfaceType.Sand;
        if (layer == LayerMask.NameToLayer("Wood")) return FootstepSurfaceType.Wood;

        return FootstepSurfaceType.Ink;
    }
}
