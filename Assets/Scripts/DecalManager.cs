using UnityEngine;

public class DecalManager : MonoBehaviour
{
    private void OnEnable()
    {
        switch (GameManager.Instance.GetPlayer().GetComponent<PlayerStateMachine>().playerState)
        {
            case PlayerStates.BLUE:
                // GetComponent<MeshRenderer>().material.SetColor("_Color", Color.blue);
                GetComponent<MeshRenderer>().material.color = Color.blue;
                break;
            
            case PlayerStates.GREY:
                GetComponent<MeshRenderer>().material.SetColor("_Color", Color.grey);
                break;
            
            case PlayerStates.BLACK:
                GetComponent<MeshRenderer>().material.SetColor("_Color", Color.black);
                break;

            case PlayerStates.GREEN:
                // GetComponent<MeshRenderer>().material.SetColor("_Color", Color.green);
                GetComponent<MeshRenderer>().material.color = Color.green;
                break;
        }
    }
}
