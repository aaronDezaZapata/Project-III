using System;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DecalManager : MonoBehaviour
{
    #region Variables
    
    [Header("Materials")]
    [SerializeField] private Material blackDecalMat;
    [SerializeField] private Material blueDecalMat;
    [SerializeField] private Material greenDecalMat;
    [SerializeField] private Material redDecalMat;

    #endregion
    
    private void Awake()
    {
        switch (GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().playerState)
        {
            case PlayerStates.RED:
                GetComponent<DecalProjector>().material = redDecalMat;
                break;
            
            case PlayerStates.BLUE:
                GetComponent<DecalProjector>().material = blueDecalMat;
                break;
            
            case PlayerStates.BLACK:
                GetComponent<DecalProjector>().material = blackDecalMat;
                break;

            case PlayerStates.GREEN:
                GetComponent<DecalProjector>().material = greenDecalMat;
                break;
        }
    }
}
