using System.Collections.Generic;
using UnityEngine;

public class SectionUnlocker : MonoBehaviour
{
    [SerializeField] private List<GameObject> _objectsToDisable = new List<GameObject>();

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        foreach (GameObject obj in _objectsToDisable)
            obj.SetActive(false);
    }
}
