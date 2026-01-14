using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DecalManager : MonoBehaviour
{
    [SerializeField] private Material blackDecalMat;
    [SerializeField] private Material blueDecalMat;
    [SerializeField] private Material greenDecalMat;
    [SerializeField] private Material greyDecalMat;
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
}
