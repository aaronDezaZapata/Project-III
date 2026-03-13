using System;
using System.Collections;
using UnityEngine;

public class FallingPlatformController : MonoBehaviour
{
    public bool isActivated;
    public float timeToFall;
    public float timeToRegenerate;
    public GameObject platform;

    [SerializeField] private float currentTimeToFall;
    [SerializeField] private float downfallSpeed;
    [SerializeField] private Vector3 initialPosition;
    [SerializeField] private Vector3 finalPosition;
    

    private void OnEnable()
    {
        initialPosition = transform.position;
        finalPosition = new Vector3(transform.position.x, transform.position.y - 20f, transform.position.z);
        currentTimeToFall = timeToFall;
    }


    private void Update()
    {
        if (!isActivated) return;
        
        currentTimeToFall -= Time.deltaTime;
        if (currentTimeToFall <= 0f)
        {
            FallingTrigger();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            other.gameObject.transform.parent = transform;
            isActivated = true;
        }
    }

    private void OnTriggerExit(Collider other) 
    {
        if (other.CompareTag("Player"))
        {
            other.gameObject.transform.parent = null;
        }
        
    }

    private void FallingTrigger()
    {
        transform.position = Vector3.MoveTowards(transform.position, finalPosition, Time.deltaTime * downfallSpeed);
        
        if (Vector3.Distance(transform.position, finalPosition) < 0.01f)
        {
            isActivated = false;
            StartCoroutine(RegeneratePlatform());
        }
    }
    
    private IEnumerator RegeneratePlatform()
    {
        yield return new WaitForSeconds(timeToRegenerate);
        transform.position = initialPosition;
        currentTimeToFall = timeToFall;
    }
}
