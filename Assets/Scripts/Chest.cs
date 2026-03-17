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
    [SerializeField] private float flightDuration = 1.0f;
    [SerializeField] private float lootDelay = 0.5f;
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
        Debug.Log($"[Chest] {gameObject.name} interaction received. isOpened: {isOpened}");
        if (isOpened) return;

        isOpened = true;
        
        // Unsubscribe immediately to prevent double-activations
        InputHandler.InteractionEvent -= OpenChest;

        // Play animation
        if (animator != null)
        {
            Debug.Log($"[Chest] Playing animation with parameter: {openParameter}");
            animator.SetBool(openParameter, true);
        }

        // Spawn loot with delay
        StartCoroutine(SpawnLootWithDelay());
    }

    private IEnumerator SpawnLootWithDelay()
    {
        yield return new WaitForSeconds(lootDelay);

        if (coinPrefab == null)
        {
            Debug.LogError("[Chest] Coin Prefab is NOT assigned in the Inspector!");
            yield break;
        }

        if (targetPoints == null || targetPoints.Length == 0)
        {
            Debug.LogError("[Chest] Target Points are NOT assigned in the Inspector!");
            yield break;
        }

        Debug.Log($"[Chest] Spawning {Mathf.Min(2, targetPoints.Length)} coins.");

        // Spawn 2 coins as requested (or as many as targets provided)
        int coinsToSpawn = Mathf.Min(2, targetPoints.Length);
        
        for (int i = 0; i < coinsToSpawn; i++)
        {
            GameObject coin = Instantiate(coinPrefab, spawnPoint != null ? spawnPoint.position : transform.position, Quaternion.identity);
            
            // Start the flight coroutine
            StartCoroutine(FlyToTarget(coin.transform, targetPoints[i]));
        }
    }

    private IEnumerator FlyToTarget(Transform item, Transform target)
    {
        Vector3 startPos = item.position;
        float elapsed = 0;

        // Disable collider or gravity during flight if necessary (depends on original coin prefab)
        Collider col = item.GetComponent<Collider>();
        if (col != null) col.enabled = false;

        while (elapsed < flightDuration)
        {
            if (item == null) yield break; // Safety check in case it's destroyed

            elapsed += Time.deltaTime;
            float t = flightCurve.Evaluate(elapsed / flightDuration);
            
            // Move item to target
            item.position = Vector3.Lerp(startPos, target.position, t);
            
            yield return null;
        }

        // Final position
        if (item != null && target != null)
        {
            item.position = target.position;
            // Re-enable collider so it can be picked up
            if (col != null) col.enabled = true;
        }
    }
}
