using UnityEngine;

public class FruitSpawner : MonoBehaviour
{
    [Header("Fruit Prefabs")]
    [SerializeField] private GameObject[] _fruitPrefabs;
    [SerializeField] private FruitPath[]  _availablePaths;

    [Header("Spawn")]
    [SerializeField] private float _spawnInterval  = 2f;
    [SerializeField] private bool  _spawnOnStart   = true;
    [SerializeField] private int   _maxFruitsAlive = 20;

    private float _timer;
    private int _currentAlive;

    private void Start()
    {
        if (_spawnOnStart)
            SpawnFruit();
    }

    private void Update()
    {
        _timer += Time.deltaTime;

        if (_timer >= _spawnInterval)
        {
            _timer = 0f;

            if (_currentAlive < _maxFruitsAlive)
                SpawnFruit();
        }
    }

    public void SpawnFruit()
    {
        if (_fruitPrefabs == null || _fruitPrefabs.Length == 0) return;
        if (_availablePaths == null || _availablePaths.Length == 0) return;

        GameObject selectedPrefab = _fruitPrefabs[Random.Range(0, _fruitPrefabs.Length)];
        if (selectedPrefab == null) return;

        FruitPath selectedPath = _availablePaths[Random.Range(0, _availablePaths.Length)];
        if (selectedPath == null || selectedPath.PointCount == 0) return;

        GameObject fruit = Instantiate(selectedPrefab, selectedPath.GetPoint(0), Quaternion.identity);

        FruitPathFollower follower = fruit.GetComponent<FruitPathFollower>();
        if (follower != null)
            follower.SetPath(selectedPath);

        FruitSpawnerCounter counter = fruit.GetComponent<FruitSpawnerCounter>();
        if (counter == null)
            counter = fruit.AddComponent<FruitSpawnerCounter>();

        counter.Spawner = this;
        _currentAlive++;
    }

    public void NotifyFruitDestroyed()
    {
        _currentAlive = Mathf.Max(0, _currentAlive - 1);
    }
}
