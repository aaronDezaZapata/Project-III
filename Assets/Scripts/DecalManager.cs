using UnityEngine;

public class DecalManager : MonoBehaviour
{
    private void Awake()
    {
        switch (GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().playerState)
        {
            case PlayerStates.BLUE:
                GetComponent<Renderer>().material.SetColor("_Color", Color.blue);
                break;
            
            case PlayerStates.GREY:
                GetComponent<Renderer>().material.SetColor("_Color", Color.grey);
                break;
            
            case PlayerStates.BLACK:
                GetComponent<Renderer>().material.SetColor("_Color", Color.black);
                break;

            case PlayerStates.GREEN:
                GetComponent<Renderer>().material.SetColor("_Color", Color.green);
                break;

            default:
                break;
        }
    }
}
