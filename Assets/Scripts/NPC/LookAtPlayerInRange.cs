using UnityEngine;

public class LookAtPlayerInRange : MonoBehaviour
{
    [Header("Referencias")]
    [SerializeField] private Transform player;

    [Header("Rango")]
    [SerializeField] private float detectionRange = 4f;

    [Header("Rotación")]
    [SerializeField] private float rotationSpeed = 5f;

    [Header("Ejes permitidos")]
    [SerializeField] private bool rotateX = false;
    [SerializeField] private bool rotateY = true;
    [SerializeField] private bool rotateZ = false;

    [Header("Opciones")]
    [SerializeField] private bool invertLookDirection = false;

    private Quaternion initialRotation;

    private void Start()
    {
        initialRotation = transform.rotation;

        if (player == null)
        {
            GameObject playerObj = GameObject.FindGameObjectWithTag("Player");

            if (playerObj != null)
            {
                player = playerObj.transform;
            }
        }
    }

    private void Update()
    {
        if (player == null) return;

        float distanceToPlayer = Vector3.Distance(transform.position, player.position);

        if (distanceToPlayer <= detectionRange)
        {
            LookAtPlayer();
        }
        else
        {
            ReturnToInitialRotation();
        }
    }

    private void LookAtPlayer()
    {
        Vector3 direction = player.position - transform.position;

        if (invertLookDirection)
        {
            direction = -direction;
        }

        if (direction == Vector3.zero) return;

        Quaternion lookRotation = Quaternion.LookRotation(direction);

        Vector3 targetEuler = lookRotation.eulerAngles;
        Vector3 currentEuler = transform.rotation.eulerAngles;

        float finalX = rotateX ? targetEuler.x : currentEuler.x;
        float finalY = rotateY ? targetEuler.y : currentEuler.y;
        float finalZ = rotateZ ? targetEuler.z : currentEuler.z;

        Quaternion targetRotation = Quaternion.Euler(finalX, finalY, finalZ);

        transform.rotation = Quaternion.Slerp(
            transform.rotation,
            targetRotation,
            rotationSpeed * Time.deltaTime
        );
    }

    private void ReturnToInitialRotation()
    {
        transform.rotation = Quaternion.Slerp(
            transform.rotation,
            initialRotation,
            rotationSpeed * Time.deltaTime
        );
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(transform.position, detectionRange);
    }
}