using UnityEngine;

public class FruitSpawnerCounter : MonoBehaviour
{
    public FruitSpawner spawner;

    private void OnDestroy()
    {
        if (spawner != null)
        {
            spawner.NotifyFruitDestroyed();
        }
    }
}