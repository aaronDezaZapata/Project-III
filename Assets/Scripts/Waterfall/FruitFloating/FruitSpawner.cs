using UnityEngine;

public class FruitSpawner : MonoBehaviour
{
    [Header("Fruit Prefabs")]
    public GameObject[] fruitPrefabs;

    public FruitPath[] availablePaths;

    [Header("Spawn")]
    public float spawnInterval = 2f;
    public bool spawnOnStart = true;
    public int maxFruitsAlive = 20;

    private float timer;
    private int currentAlive;

    private void Start()
    {
        if (spawnOnStart)
        {
            SpawnFruit();
        }
    }

    private void Update()
    {
        timer += Time.deltaTime;

        if (timer >= spawnInterval)
        {
            timer = 0f;

            if (currentAlive < maxFruitsAlive)
            {
                SpawnFruit();
            }
        }
    }

    public void SpawnFruit()
    {
        if (fruitPrefabs == null || fruitPrefabs.Length == 0)
            return;

        if (availablePaths == null || availablePaths.Length == 0)
            return;

        GameObject selectedFruitPrefab = fruitPrefabs[Random.Range(0, fruitPrefabs.Length)];

        if (selectedFruitPrefab == null)
            return;

        FruitPath selectedPath = availablePaths[Random.Range(0, availablePaths.Length)];

        if (selectedPath == null || selectedPath.PointCount == 0)
            return;

        GameObject fruit = Instantiate(
            selectedFruitPrefab,
            selectedPath.GetPoint(0),
            Quaternion.identity
        );

        FruitPathFollower follower = fruit.GetComponent<FruitPathFollower>();

        if (follower != null)
        {
            follower.SetPath(selectedPath);
        }

        FruitSpawnerCounter counter = fruit.GetComponent<FruitSpawnerCounter>();

        if (counter == null)
        {
            counter = fruit.AddComponent<FruitSpawnerCounter>();
        }

        counter.spawner = this;

        currentAlive++;
    }

    public void NotifyFruitDestroyed()
    {
        currentAlive = Mathf.Max(0, currentAlive - 1);
    }
}