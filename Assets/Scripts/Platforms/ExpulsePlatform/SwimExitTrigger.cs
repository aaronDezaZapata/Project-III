using UnityEngine;

public class SwimExitTrigger : MonoBehaviour
{
    [Header("Expulsion Settings")]
    [SerializeField] private float pushForce = 8f;

    [SerializeField] private bool pushAwayFromThisObject = true;

    [SerializeField] private Vector3 manualPushDirection = Vector3.up;

    private void OnTriggerEnter(Collider other)
    {
        PlayerStateMachine player = other.GetComponentInParent<PlayerStateMachine>();

        if (player == null)
            return;

        Vector3 pushDirection;

        if (pushAwayFromThisObject)
        {
            pushDirection = player.transform.position - transform.position;
            pushDirection.y += 0.5f;
        }
        else
        {
            pushDirection = manualPushDirection;
        }

        player.ForceExitSwimState(pushDirection, pushForce);
    }
}