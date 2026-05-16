using UnityEngine;
using System.Collections;

public class Chest : MonoBehaviour
{
    [Header("Animation Settings")]
    [SerializeField] private Animator _animator;
    [SerializeField] private string _openParameter = "isOpened";

    [Header("Loot Settings")]
    [SerializeField] private GameObject _coinPrefab;
    [SerializeField] private Transform _spawnPoint;
    [SerializeField] private Transform[] _targetPoints;
    [SerializeField] private float _lootDelay     = 0.5f;
    [SerializeField] private float _flightDuration = 1.0f;
    [SerializeField] private AnimationCurve _flightCurve = AnimationCurve.EaseInOut(0, 0, 1, 1);

    private bool _isOpened;

    private void OnTriggerEnter(Collider other)
    {
        if (_isOpened || !other.CompareTag("Player")) return;
        InputHandler.InteractionEvent += OpenChest;
    }

    private void OnTriggerExit(Collider other)
    {
        if (!other.CompareTag("Player")) return;
        InputHandler.InteractionEvent -= OpenChest;
    }

    private void OpenChest()
    {
        if (_isOpened) return;

        _isOpened = true;
        InputHandler.InteractionEvent -= OpenChest;

        if (_animator != null)
            _animator.SetBool(_openParameter, true);

        StartCoroutine(SpawnLootWithDelay());
    }

    private IEnumerator SpawnLootWithDelay()
    {
        yield return new WaitForSeconds(_lootDelay);

        if (_coinPrefab == null || _targetPoints == null || _targetPoints.Length == 0)
            yield break;

        for (int i = 0; i < _targetPoints.Length; i++)
        {
            Vector3 spawnPos = _spawnPoint != null ? _spawnPoint.position : transform.position;
            GameObject coin  = Instantiate(_coinPrefab, spawnPos, Quaternion.identity);
            StartCoroutine(FlyToTarget(coin.transform, _targetPoints[i]));
        }
    }

    private IEnumerator FlyToTarget(Transform item, Transform target)
    {
        Vector3 startPos = item.position;
        float elapsed    = 0f;

        Collider col = item.GetComponent<Collider>();
        if (col != null) col.enabled = false;

        while (elapsed < _flightDuration)
        {
            if (item == null) yield break;

            elapsed += Time.deltaTime;
            float t  = _flightCurve.Evaluate(elapsed / _flightDuration);
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
