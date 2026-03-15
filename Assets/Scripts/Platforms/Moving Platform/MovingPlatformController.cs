using System;
using UnityEngine;

public class MovingPlatformController : MonoBehaviour
{
    [Header("Platform Settings")]
    [SerializeField] private Transform platform;
    [SerializeField] private float speed = 2f;
    
    [Header("Waypoints")]
    [SerializeField] private Transform[] waypoints;
    
    private int currentWaypointIndex = 0;
    private bool movingForward = true;

    private void Start()
    {
        platform.transform.position = waypoints[0].position;
    }

    void Update()
    {
        if (waypoints == null || waypoints.Length == 0 || platform == null)
            return;

        MovePlatform();
    }

    private void MovePlatform()
    {
        Transform targetWaypoint = waypoints[currentWaypointIndex];
        
        platform.position = Vector3.MoveTowards(
            platform.position, 
            targetWaypoint.position, 
            speed * Time.deltaTime
        );
        
        if (Vector3.Distance(platform.position, targetWaypoint.position) < 0.01f)
        {
            currentWaypointIndex++;
            
            if (currentWaypointIndex >= waypoints.Length)
            {
                currentWaypointIndex = 0;
            }
        }
    }
    
    private void OnDrawGizmos()
    {
        if (waypoints == null || waypoints.Length == 0)
            return;

        Gizmos.color = Color.yellow;
        
        for (int i = 0; i < waypoints.Length; i++)
        {
            if (waypoints[i] == null)
                continue;
            
            Gizmos.DrawWireSphere(waypoints[i].position, 0.3f);
            
            int nextIndex = (i + 1) % waypoints.Length;
            if (waypoints[nextIndex] != null)
            {
                Gizmos.DrawLine(waypoints[i].position, waypoints[nextIndex].position);
            }
        }
    }
}
