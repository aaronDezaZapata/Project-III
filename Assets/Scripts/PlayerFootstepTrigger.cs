using System;
using UnityEngine;

public class PlayerFootstepTrigger : MonoBehaviour
{
    [SerializeField] private PlayerStateMachine player;

    private void OnTriggerEnter(Collider other)
    {
        player.PlayFootstepParticle();
    }
}
