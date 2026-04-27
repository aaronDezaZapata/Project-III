using UnityEngine;

public class PlayerAnimationEvents : MonoBehaviour
{
    private PlayerStateMachine _stateMachine;

    private void Awake()
    {
        // Busca el PlayerStateMachine en este objeto o en los padres (el Root del Player)
        _stateMachine = GetComponentInParent<PlayerStateMachine>();
    }

    // Esta es la función que el Animator podrá encontrar en la ventana Animation
    public void PlayFootstepParticle()
    {
        if (_stateMachine != null)
        {
            _stateMachine.PlayFootstepParticle();
        }
    }
}
