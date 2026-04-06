using UnityEngine;

public class PlayerAnimationEvents : MonoBehaviour
{
    private PlayerStateMachine _stateMachine;

    private void Awake()
    {
        // Busca el PlayerStateMachine en este objeto o en los padres (el Root del Player)
        _stateMachine = GetComponentInParent<PlayerStateMachine>();
        
        if (_stateMachine == null)
        {
            Debug.LogError("PlayerAnimationEvents: No se encontró el PlayerStateMachine en el objeto o sus padres.", this);
        }
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
