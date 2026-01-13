using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;
    
    public List<PaintableEnemy> enemiesPainted;

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

    public void AddPaintedEnemy(PaintableEnemy enemy)
    {
        enemiesPainted.Add(enemy);
    }

    public void RemovePaintedEnemy(PaintableEnemy enemy)
    {
        enemiesPainted.Remove(enemy);
    }
}
