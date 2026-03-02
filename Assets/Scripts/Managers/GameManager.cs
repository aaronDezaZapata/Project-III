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

    public void RemoveCurrentDecals()
    {
        foreach (GameObject decal in levelDecals)
        {
            Destroy(decal);
        }
        
        levelDecals.Clear();
    }
    
    // TODO: Remove
    // No hay enemigos
    /*public void AddPaintedEnemy(PaintableEnemy enemy)
    {
        enemiesPainted.Add(enemy);
    }*/
    // TODO: Remove
    // No hay enemigos
    /*public void RemovePaintedEnemy(PaintableEnemy enemy)
    {
        enemiesPainted.Remove(enemy);
    }*/

    public void GetNewCheckPoint(Transform newCheckPoint)
    {
        currentCheckPoint = newCheckPoint;
    }

    public void PlayerDeath()
    {
        //SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);

        player.transform.position = currentCheckPoint.transform.position;
        player.transform.rotation = currentCheckPoint.transform.rotation;
    }
}
