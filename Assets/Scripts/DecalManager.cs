using System;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DecalManager : MonoBehaviour
{
    #region Variables

    [Header("Decal Settings")] 
    [SerializeField] private bool isInitialized;
    [SerializeField] private float currentTimeToLive;
    
    [Header("Materials")]
    [SerializeField] private Material blackDecalMat;
    [SerializeField] private Material blueDecalMat;
    [SerializeField] private Material greenDecalMat;
    [SerializeField] private Material greyDecalMat;

    #endregion
    
    private void Awake()
    {
        switch (GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().playerState)
        {
            case PlayerStates.BLUE:
                // GetComponent<MeshRenderer>().material.SetColor("_Color", Color.blue);
                GetComponent<DecalProjector>().material = blueDecalMat;
                break;
            
            case PlayerStates.GREY:
                GetComponent<DecalProjector>().material = greyDecalMat;
                break;
            
            case PlayerStates.BLACK:
                GetComponent<DecalProjector>().material = blackDecalMat;
                break;

            case PlayerStates.GREEN:
                GetComponent<DecalProjector>().material = greenDecalMat;
                break;
        }
    }

    private void FixedUpdate()
    {
        currentTimeToLive -= Time.deltaTime;

        if (currentTimeToLive <= 0)
        {
            Destroy(gameObject);
        }
    }

    public void InitializeInkDecal(float timeToLive)
    {
        isInitialized = true;
        currentTimeToLive = timeToLive;
    }
}
