using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;
    
    public List<PaintableEnemy> enemiesPainted;

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


    [SerializeField] Transform player;


    public Transform GetPlayer()
    {
        return player;
    }

    public void AddPaintedEnemy(PaintableEnemy enemy)
    {
        enemiesPainted.Add(enemy);
    }

    public void RemovePaintedEnemy(PaintableEnemy enemy)
    {
        enemiesPainted.Remove(enemy);
    }

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
