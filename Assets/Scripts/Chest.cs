using UnityEngine;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// Chest that can be opened by the player.
/// Spawns 2 coins that fly to specific target points.
/// </summary>
public class Chest : MonoBehaviour
{
    [Header("Animation Settings")]
    [SerializeField] private Animator animator;
    [SerializeField] private string openParameter = "isOpened";

    [Header("Loot Settings")]
    [SerializeField] private GameObject coinPrefab;
    [SerializeField] private Transform spawnPoint;
    [SerializeField] private Transform[] targetPoints;
    [SerializeField] private float lootDelay = 0.5f;
    [SerializeField] private float flightDuration = 1.0f;
    [SerializeField] private AnimationCurve flightCurve = AnimationCurve.EaseInOut(0, 0, 1, 1);

    private bool isOpened = false;

    private void OnTriggerEnter(Collider other)
    {
        if (isOpened) return;
        if (!other.CompareTag("Player")) return;

        InputHandler.InteractionEvent += OpenChest;
    }

    private void OnTriggerExit(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        InputHandler.InteractionEvent -= OpenChest;
    }

    private void OpenChest()
    {
        
        if (isOpened) return;

        isOpened = true;
        

        InputHandler.InteractionEvent -= OpenChest;


        if (animator != null)
        {
            
            animator.SetBool(openParameter, true);
        }


        StartCoroutine(SpawnLootWithDelay());
    }

    private IEnumerator SpawnLootWithDelay()
    {
        yield return new WaitForSeconds(lootDelay);

        if (coinPrefab == null)
        {
            
            yield break;
        }

        if (targetPoints == null || targetPoints.Length == 0)
        {
            
            yield break;
        }

        

        
        
        for (int i = 0; i < targetPoints.Length; i++)
        {
            GameObject coin = Instantiate(coinPrefab, spawnPoint != null ? spawnPoint.position : transform.position, Quaternion.identity);
            
            StartCoroutine(FlyToTarget(coin.transform, targetPoints[i]));
        }
    }

    private IEnumerator FlyToTarget(Transform item, Transform target)
    {
        Vector3 startPos = item.position;
        float elapsed = 0;

        
        Collider col = item.GetComponent<Collider>();
        if (col != null) col.enabled = false;

        while (elapsed < flightDuration)
        {
            if (item == null) yield break; 

            elapsed += Time.deltaTime;
            float t = flightCurve.Evaluate(elapsed / flightDuration);
            
           
            item.position = Vector3.Lerp(startPos, target.position, t);
            
            yield return null;
        }

      
        if (item != null && target != null)
        {
            item.position = target.position;
            
            if (col != null) col.enabled = true;
        }
    }
}
