using UnityEngine;

public class PlayerAnimationEvents : MonoBehaviour
{
    private PlayerStateMachine _stateMachine;

    private void Awake()
    {
        _stateMachine = GetComponentInParent<PlayerStateMachine>();

        if (_stateMachine == null)
        {
            Debug.LogError("PlayerAnimationEvents: No se ha encontrado PlayerStateMachine en los padres.");
        }
        else
        {
            Debug.Log("PlayerAnimationEvents: PlayerStateMachine encontrada correctamente.");
        }
    }

    public void PlayFootstepParticle()
    {
        Debug.Log("ANIMATION EVENT: PlayFootstepParticle llamado.");

        if (_stateMachine != null)
        {
            _stateMachine.PlayFootstepParticle();
        }
    }
}