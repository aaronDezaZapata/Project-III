using UnityEngine;

public class FruitPathFollower : MonoBehaviour
{
    public FruitPath path;
    public float speed = 3f;
    public float rotationSpeed = 8f;
    public float pointReachDistance = 0.2f;
    public bool destroyAtEnd = true;

    private int currentPointIndex = 0;

    public void SetPath(FruitPath newPath)
    {
        path = newPath;
        currentPointIndex = 0;

        if (path != null && path.PointCount > 0)
        {
            transform.position = path.GetPoint(0);
        }
    }

    private void Update()
    {
        if (path == null || path.PointCount == 0) return;
        if (currentPointIndex >= path.PointCount) return;

        Vector3 target = path.GetPoint(currentPointIndex);
        Vector3 direction = target - transform.position;

        if (direction.magnitude <= pointReachDistance)
        {
            currentPointIndex++;

            if (currentPointIndex >= path.PointCount)
            {
                if (destroyAtEnd)
                    Destroy(gameObject);

                return;
            }

            target = path.GetPoint(currentPointIndex);
            direction = target - transform.position;
        }

        Vector3 moveDir = direction.normalized;
        transform.position += moveDir * speed * Time.deltaTime;

        if (moveDir != Vector3.zero)
        {
            Quaternion targetRot = Quaternion.LookRotation(moveDir);
            transform.rotation = Quaternion.Slerp(
                transform.rotation,
                targetRot,
                rotationSpeed * Time.deltaTime
            );
        }
    }
}