using UnityEngine;

public class ShaderPlayerDataSender : MonoBehaviour
{
    [SerializeField] private Transform trackedPoint;

    private Vector3 lastPosition;
    private Vector3 velocity;

    private static readonly int PlayerPositionID = Shader.PropertyToID("_PlayerPositionWS");
    private static readonly int PlayerVelocityID = Shader.PropertyToID("_PlayerVelocityWS");

    private void Start()
    {
        if (trackedPoint == null)
        {
            Debug.LogError("ShaderPlayerDataSender: trackedPoint no asignado.");
            enabled = false;
            return;
        }

        lastPosition = trackedPoint.position;
        Debug.Log("ShaderPlayerDataSender iniciado con trackedPoint: " + trackedPoint.name);
    }

    private void Update()
    {
        Vector3 currentPosition = trackedPoint.position;
        velocity = (currentPosition - lastPosition) / Mathf.Max(Time.deltaTime, 0.0001f);

        Shader.SetGlobalVector(PlayerPositionID, currentPosition);
        Shader.SetGlobalVector(PlayerVelocityID, velocity);

        Debug.Log("Tracked Pos: " + currentPosition + " | Velocity: " + velocity);

        lastPosition = currentPosition;
    }
}