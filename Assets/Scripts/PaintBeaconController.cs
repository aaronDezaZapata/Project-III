using System;
using Unity.VisualScripting;
using UnityEngine;

public class PaintBeaconController : MonoBehaviour
{
    public bool isReusable;

    [SerializeField] private bool isUsed;
    
    private void OnTriggerEnter(Collider other)
    {
        if (!isReusable)
            if (isUsed) return;
        
        if (other.CompareTag("Player"))
        {
            GameManager.Instance.paintBeacon = null;
            isUsed = true;
        }
        else
        {
            GameManager.Instance.paintBeacon = gameObject;
        }
    }
}
