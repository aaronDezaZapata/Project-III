using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class FruitWaterfall : MonoBehaviour
{
    private Rigidbody rb;

    [Header("Movimiento base")]
    public float floatForce = 3f;         // empuje suave hacia arriba en agua horizontal
    public float waterDrag = 2f;          // freno general en agua
    public float maxSpeed = 8f;

    [Header("Estado actual")]
    public bool inHorizontalWater;
    public bool inVerticalWater;

    private Vector3 currentFlowDirection = Vector3.zero;
    private float currentFlowStrength = 0f;

    void Awake()
    {
        rb = GetComponent<Rigidbody>();
        rb.useGravity = false;
    }

    void FixedUpdate()
    {
        // Frenado general para que no salga disparada
        rb.linearDamping = waterDrag;

        // En agua horizontal: flota un poco
        if (inHorizontalWater)
        {
            rb.AddForce(Vector3.up * floatForce, ForceMode.Acceleration);
        }

        // En cascada vertical: se deja arrastrar
        if (inVerticalWater)
        {
            rb.AddForce(currentFlowDirection.normalized * currentFlowStrength, ForceMode.Acceleration);
        }

        // Limitar velocidad
        if (rb.linearVelocity.magnitude > maxSpeed)
        {
            rb.linearVelocity = rb.linearVelocity.normalized * maxSpeed;
        }
    }

    public void EnterVerticalFlow(Vector3 dir, float strength)
    {
        inVerticalWater = true;
        currentFlowDirection = dir;
        currentFlowStrength = strength;
    }

    public void ExitVerticalFlow()
    {
        inVerticalWater = false;
        currentFlowDirection = Vector3.zero;
        currentFlowStrength = 0f;
    }

    public void EnterHorizontalWater()
    {
        inHorizontalWater = true;
    }

    public void ExitHorizontalWater()
    {
        inHorizontalWater = false;
    }

    private void OnTriggerEnter(Collider other)
    {
        // Si toca el plano final, destruir
        if (other.CompareTag("KillFruit"))
        {
            Destroy(gameObject);
        }
    }
}