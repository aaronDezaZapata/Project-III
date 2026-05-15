using UnityEngine;

public class FruitPathFollower : MonoBehaviour
{
    [System.Serializable]
    public class SpeedRange
    {
        [Tooltip("Desde este punto empieza este rango")]
        public int startPointIndex = 0;

        [Tooltip("Hasta este punto se aplica este rango")]
        public int endPointIndex = 1;

        [Tooltip("Velocidad objetivo en este tramo")]
        public float targetSpeed = 5f;

        [Tooltip("Qué tan rápido acelera hacia esa velocidad")]
        public float acceleration = 2f;
    }

    public FruitPath path;

    [Header("Movimiento general")]
    public float baseSpeed = 3f;
    public float currentSpeed = 3f;
    public float rotationSpeed = 8f;
    public float pointReachDistance = 0.2f;
    public bool destroyAtEnd = true;

    [Header("Sube y baja")]
    public float bobHeight = 0.3f;
    public float bobSpeed = 2f;
    public float tiltAmount = 8f;
    public float tiltSpeed = 2f;

    [Header("Tramos de velocidad")]
    public SpeedRange[] speedRanges;

    private int currentPointIndex = 0;
    private Vector3 basePosition;
    private float randomOffset;

    public void SetPath(FruitPath newPath)
    {
        path = newPath;
        currentPointIndex = 0;
        randomOffset = Random.Range(0f, 100f);

        currentSpeed = baseSpeed;

        if (path != null && path.PointCount > 0)
        {
            transform.position = path.GetPoint(0);
            basePosition = transform.position;
        }
    }

    private void Start()
    {
        randomOffset = Random.Range(0f, 100f);
        currentSpeed = baseSpeed;

        if (path != null && path.PointCount > 0)
        {
            basePosition = transform.position;
        }
    }

    private void Update()
    {
        if (path == null || path.PointCount == 0) return;
        if (currentPointIndex >= path.PointCount) return;

        UpdateSpeedByRange();

        Vector3 target = path.GetPoint(currentPointIndex);
        Vector3 flatDirection = target - basePosition;

        if (flatDirection.magnitude <= pointReachDistance)
        {
            currentPointIndex++;

            if (currentPointIndex >= path.PointCount)
            {
                if (destroyAtEnd)
                    Destroy(gameObject);

                return;
            }

            target = path.GetPoint(currentPointIndex);
            flatDirection = target - basePosition;
        }

        Vector3 moveDir = flatDirection.normalized;
        basePosition += moveDir * currentSpeed * Time.deltaTime;

        float bobOffset = Mathf.Sin((Time.time + randomOffset) * bobSpeed) * bobHeight;
        Vector3 finalPosition = basePosition + Vector3.up * bobOffset;
        transform.position = finalPosition;

        if (moveDir != Vector3.zero)
        {
            Quaternion lookRot = Quaternion.LookRotation(moveDir);

            float tiltZ = Mathf.Sin((Time.time + randomOffset) * tiltSpeed) * tiltAmount;
            Quaternion tiltRot = Quaternion.Euler(0f, 0f, tiltZ);

            Quaternion targetRot = lookRot * tiltRot;

            transform.rotation = Quaternion.Slerp(
                transform.rotation,
                targetRot,
                rotationSpeed * Time.deltaTime
            );
        }
    }

    private void UpdateSpeedByRange()
    {
        float targetSpeed = baseSpeed;
        float accel = 999f; 

        if (speedRanges != null)
        {
            for (int i = 0; i < speedRanges.Length; i++)
            {
                SpeedRange range = speedRanges[i];
                if (range == null) continue;

                if (currentPointIndex >= range.startPointIndex && currentPointIndex <= range.endPointIndex)
                {
                    targetSpeed = range.targetSpeed;
                    accel = range.acceleration;
                    break;
                }
            }
        }

        currentSpeed = Mathf.MoveTowards(currentSpeed, targetSpeed, accel * Time.deltaTime);
    }
}