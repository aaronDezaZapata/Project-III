using UnityEngine;

public class FruitSpawnerCounter : MonoBehaviour
{
    public FruitSpawner Spawner { get; set; }

    private void OnDestroy()
    {
        Spawner?.NotifyFruitDestroyed();
    }
}
