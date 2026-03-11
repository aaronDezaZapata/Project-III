using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    [SerializeField] private Transform player;
    
    public static GameManager Instance;
    
    public List<GameObject> levelDecals;

    public GameObject paintBeacon;

    private Transform currentCheckPoint;
    
    // Coins
    private int coinsCollected = 0;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(this);
            return;
        }

        if (currentCheckPoint == null) return;
        GetNewCheckPoint(currentCheckPoint);
    }

    public Transform GetPlayer()
    {
        return player;
    }

    public State GetPlayerState()
    {
        return GetPlayer().GetComponent<StateMachine>().GetCurrentState(); // ya existe en StateMachine.cs
    }

    public void SetPlayerState<T>() where T : State
    {
        GetPlayer().GetComponent<StateMachine>().SwitchState(typeof(T));
    }

    public void RemoveCurrentDecals()
    {
        foreach (GameObject decal in levelDecals)
        {
            Destroy(decal);
        }
        
        levelDecals.Clear();
    }
    
    public void GetNewCheckPoint(Transform newCheckPoint)
    {
        currentCheckPoint = newCheckPoint;
    }

    public void AddCoin(int amount)
    {
        coinsCollected += amount;
        Debug.Log("Coins Collected: " + coinsCollected);
    }

    public void ResetCoinAmount()
    {
        coinsCollected = 0;
    }

    public void PlayerDeath()
    {
        //SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);

        player.transform.position = currentCheckPoint.transform.position;
        player.transform.rotation = currentCheckPoint.transform.rotation;
    }
}
