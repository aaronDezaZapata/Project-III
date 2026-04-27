using UnityEngine;

public class PlayerAnimationEvents : MonoBehaviour
{
    private PlayerStateMachine _stateMachine;

    private void Awake()
    {
        _stateMachine = GetComponentInParent<PlayerStateMachine>();

    }

    public void PlayFootstepParticle()
    {
        if (_stateMachine != null)
        {
            _stateMachine.PlayFootstepParticle();
        }
    }
}