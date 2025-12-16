using UnityEngine;
using UnityEngine.AI;

public class ForceReceiver : MonoBehaviour
{
    [SerializeField] CharacterController controller;

    [SerializeField] float drag = 0.4f;

    Vector3 dampingVelocity;

    Vector3 impact;

    float verticalVelocity;

    [SerializeField] float playerGravity;

    public Vector3 Movement => impact + Vector3.up * verticalVelocity;

    private void Update()
    {
        
        if (verticalVelocity < 0f && controller.isGrounded)
        {
            // verticalVelocity = playerGravity * Time.deltaTime;
            verticalVelocity = -2f;
        }
        else
        {
            verticalVelocity += playerGravity * Time.deltaTime;
        }

        impact = Vector3.SmoothDamp(impact, Vector3.zero, ref dampingVelocity, drag);

        // controller.Move(Movement * Time.deltaTime);
    }

    
    // Base Jump
    public void Jump(float jumpForce)
    {
        verticalVelocity = jumpForce;
    }
    
    // Resets vertical velocity
    public void ResetVerticalVelocity()
    {
        if (verticalVelocity > 0f)
        {
            verticalVelocity = 0f;
        }
    }
    
    public void AddForce(Vector3 force)
    {
        impact += force;
    }
}
