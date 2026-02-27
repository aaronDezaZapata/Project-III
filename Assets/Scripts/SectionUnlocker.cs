using System;
using System.Collections.Generic;
using NUnit.Framework;
using UnityEngine;

public class SectionUnlocker : MonoBehaviour
{
    public List<GameObject> objectsToDisable = new List<GameObject>();

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            foreach (GameObject obj in objectsToDisable)
            {
                obj.SetActive(false);
            }
        }
    }
}
