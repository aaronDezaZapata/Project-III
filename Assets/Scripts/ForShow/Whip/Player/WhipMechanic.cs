using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class WhipMechanic : MonoBehaviour
{
    [Header("Referencias Obligatorias")]
    public Camera mainCamera;
    public Transform handPosition; // La mano o punto de origen del látigo
    public Transform enemyHolder;  // Un objeto vacío hijo del Player (frente a él)
    public MonoBehaviour playerMovementScript; // ARRASTRA AQUÍ TU SCRIPT DE MOVIMIENTO (ej. ThirdPersonController)

    [Header("Configuración General")]
    public LayerMask enemyLayer;
    public LayerMask obstacleLayer;
    public LineRenderer ropeVisual;

    [Header("Mecánica de Giro")]
    public float grabRange = 25f;
    public float whipSpeed = 40f;
    public float startSpinSpeed = 100f; 
    public float spinAcceleration = 300f; 
    public float maxSpinSpeed = 1200f; 
    public float throwForce = 40f;

    
    private Rigidbody currentEnemyRB;
    private EnemyScript currentEnemyScript;
    private bool isHolding = false;
    private float currentRotationSpeed;
    private bool isWhipExtending = false;

    void Update()
    {
        
        if (Input.GetMouseButtonDown(1) && !isHolding && !isWhipExtending)
        {
            Transform target = GetBestTarget();
            if (target != null)
            {
                StartCoroutine(GrabSequence(target));
            }
        }

        
        if (Input.GetMouseButton(1) && isHolding)
        {
            HandleSpinLogic();
            UpdateRopeVisuals();
        }

        
        if (Input.GetMouseButtonUp(1) && isHolding)
        {
            ThrowEnemy();
        }
    }

    void HandleSpinLogic()
    {
        
        float inputMagnitude = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical")).magnitude;

        
        if (inputMagnitude > 0.1f)
        {
            currentRotationSpeed += spinAcceleration * Time.deltaTime;
        }
        else
        {
            
            currentRotationSpeed -= (spinAcceleration * 0.5f) * Time.deltaTime;
        }

        
        currentRotationSpeed = Mathf.Clamp(currentRotationSpeed, startSpinSpeed, maxSpinSpeed);

        
        transform.Rotate(Vector3.up * currentRotationSpeed * Time.deltaTime);
    }

    
    Transform GetBestTarget()
    {
        Collider[] enemies = Physics.OverlapSphere(transform.position, grabRange, enemyLayer);
        Transform bestTarget = null;
        float closestDistanceToCenter = Mathf.Infinity;

        foreach (Collider col in enemies)
        {
            Transform target = col.transform;
            Vector3 viewportPos = mainCamera.WorldToViewportPoint(target.position);

            // Verificar si está en pantalla
            bool onScreen = viewportPos.x > 0 && viewportPos.x < 1 && viewportPos.y > 0 && viewportPos.y < 1 && viewportPos.z > 0;

            if (onScreen)
            {
                Vector3 dirToTarget = (target.position - mainCamera.transform.position).normalized;
                float distToTarget = Vector3.Distance(mainCamera.transform.position, target.position);

                if (!Physics.Raycast(mainCamera.transform.position, dirToTarget, distToTarget, obstacleLayer))
                {
                    // Priorizar el que esté más cerca del centro
                    float distToCenter = Vector2.Distance(new Vector2(viewportPos.x, viewportPos.y), new Vector2(0.5f, 0.5f));

                    if (distToCenter < closestDistanceToCenter)
                    {
                        closestDistanceToCenter = distToCenter;
                        bestTarget = target;
                    }
                }
            }
        }
        return bestTarget;
    }


    IEnumerator GrabSequence(Transform target)
    {
        isWhipExtending = true;
        ropeVisual.enabled = true;

        
        if (playerMovementScript != null) playerMovementScript.enabled = false;

        
        float t = 0;
        Vector3 startPos = handPosition.position;
        while (t < 1)
        {
            t += Time.deltaTime * whipSpeed / Vector3.Distance(startPos, target.position);
            ropeVisual.SetPosition(0, handPosition.position);
            ropeVisual.SetPosition(1, Vector3.Lerp(startPos, target.position, t));
            yield return null;
        }

        currentEnemyRB = target.GetComponent<Rigidbody>();
        currentEnemyScript = target.GetComponent<EnemyScript>();

        if (currentEnemyRB != null)
        {
            if (currentEnemyScript != null) currentEnemyScript.Stun(true);

            currentEnemyRB.isKinematic = true;

            
            target.position = enemyHolder.position;
            target.SetParent(enemyHolder);
            target.localRotation = Quaternion.identity;

            isHolding = true;
            currentRotationSpeed = startSpinSpeed;
        }

        isWhipExtending = false;
    }

    void UpdateRopeVisuals()
    {
        if (isHolding && currentEnemyRB != null)
        {
            ropeVisual.SetPosition(0, handPosition.position);
            ropeVisual.SetPosition(1, currentEnemyRB.transform.position);
        }
    }

   
    void ThrowEnemy()
    {
        if (currentEnemyRB == null) return;

        
        currentEnemyRB.transform.SetParent(null);
        currentEnemyRB.isKinematic = false;

        
        Transform targetToHit = GetBestTarget();
        Vector3 throwDirection;

        if (targetToHit != null)
        {
            
            throwDirection = (targetToHit.position - transform.position).normalized;
        }
        else
        {
            
            throwDirection = transform.forward;
        }

        
        currentEnemyRB.AddForce(throwDirection * throwForce, ForceMode.Impulse);

        
        ropeVisual.enabled = false;
        isHolding = false;
        currentEnemyRB = null;
        currentEnemyScript = null;

        
        if (playerMovementScript != null) playerMovementScript.enabled = true;
    }
}
