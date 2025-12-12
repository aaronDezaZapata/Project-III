using UnityEngine;

public class GameManager : MonoBehaviour
{

    public static GameManager Instance;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(this);
        }
    }


    [SerializeField] Transform player;


    public Transform GetPlayer()
    {
        return player;
    }


}
