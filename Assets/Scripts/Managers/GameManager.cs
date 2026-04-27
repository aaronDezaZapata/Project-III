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

    public Action<string> OnLeverActivated;

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
        return GetPlayer().GetComponent<StateMachine>().GetCurrentState(); 
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
    }

    public void ResetCoinAmount()
    {
        coinsCollected = 0;
    }

    private void Update()
    {
        // L3 + R3 simultáneamente es toggle FlyState 
        bool leftStick  = Input.GetKeyDown(KeyCode.JoystickButton8);   // L3
        bool rightStick = Input.GetKey(KeyCode.JoystickButton9);        // R3

        if (leftStick && rightStick)
        {
            if (GetPlayerState() is PlayerFlyState)
            {
                // Salir del fly state y volver al estado de color actual
                player.GetComponent<PlayerStateMachine>().ReturnToMainState();
            }
            else
            {
                // Entrar en fly state
                SetPlayerState<PlayerFlyState>();
            }
        }
    }

    public void PlayerDeath()
    {
        player.transform.position = currentCheckPoint.transform.position;
        player.transform.rotation = currentCheckPoint.transform.rotation;
    }
}
