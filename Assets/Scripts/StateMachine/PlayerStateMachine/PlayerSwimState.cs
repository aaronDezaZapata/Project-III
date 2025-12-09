using UnityEngine;

public class PlayerSwimState : PlayerBaseState
{
    private float originalHeight;
    private Vector3 originalCenter;
    private Vector3 swimVelocity;
    private float timeWithoutInk = 0f;

    public PlayerSwimState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }



    public override void Enter()
    {
        originalHeight = stateMachine.Controller.height;
        originalCenter = stateMachine.Controller.center;

        // Forma de calamar
        stateMachine.Controller.height = 0.5f;
        stateMachine.Controller.center = new Vector3(0, 0.25f, 0);

        swimVelocity = Vector3.zero;

        // Reset inicial
        stateMachine.ForceReceiver.enabled = false;
    }

    public override void Tick(float deltaTime)
    {
        stateMachine.CheckForInk();
        stateMachine.ForceReceiver.enabled = false;

        
        if (!stateMachine.IsOnInk)
        {
            timeWithoutInk += deltaTime;
            
            if (timeWithoutInk > 0.15f)
            {
                stateMachine.SwitchState(typeof(PlayerFreeLookState));
                return;
            }
        }
        else
        {
            // Si detectamos tinta, reseteamos el contador
            timeWithoutInk = 0f;
        }

        
        if (Input.GetKeyDown(KeyCode.N))
        {
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }

        if(Input.GetKeyDown(KeyCode.Space))
        {
            PerformInkJump();
        }

        
        HandleSwimMovement(deltaTime);
    }

    public override void Exit()
    {
        stateMachine.Controller.height = originalHeight;
        stateMachine.Controller.center = originalCenter;

        // Al salir, rotamos suavemente hacia arriba global
        stateMachine.transform.rotation = Quaternion.FromToRotation(stateMachine.transform.up, Vector3.up) * stateMachine.transform.rotation;

        stateMachine.ForceReceiver.enabled = true;
    }

    private void HandleSwimMovement(float deltaTime)
    {
        Vector2 input = stateMachine.InputReader.MoveVector;
        Vector3 surfaceNormal = stateMachine.CurrentInkNormal;

        Vector3 cameraRight = Camera.main.transform.right;

        Vector3 rightProjected = Vector3.ProjectOnPlane(cameraRight, surfaceNormal).normalized;

        Vector3 forwardProjected = Vector3.Cross(rightProjected, surfaceNormal);

        Vector3 moveDir = (forwardProjected * input.y + rightProjected * input.x).normalized;

        if (moveDir != Vector3.zero)
        {
            Quaternion targetRotation = Quaternion.LookRotation(moveDir, surfaceNormal);
            stateMachine.transform.rotation = Quaternion.Slerp(stateMachine.transform.rotation, targetRotation, deltaTime * 20f);
        }
        else
        {
            Quaternion targetRotation = Quaternion.FromToRotation(stateMachine.transform.up, surfaceNormal) * stateMachine.transform.rotation;
            stateMachine.transform.rotation = Quaternion.Slerp(stateMachine.transform.rotation, targetRotation, deltaTime * 10f);
        }

        if (moveDir.magnitude > 0.1f)
        {
            swimVelocity = Vector3.MoveTowards(swimVelocity, moveDir * stateMachine.SwimSpeed, 60f * deltaTime);
        }
        else
        {
            swimVelocity = Vector3.MoveTowards(swimVelocity, Vector3.zero, 40f * deltaTime);
        }

        //  GRAVEDAD DE ADHERENCIA
        Vector3 stickForce = -surfaceNormal * 5f;

        stateMachine.Controller.Move((swimVelocity + stickForce) * deltaTime);
    }

    private void PerformInkJump()
    {
        Vector3 jumpDir = stateMachine.CurrentInkNormal + (stateMachine.transform.forward * 0.5f);
        if(!stateMachine.ForceReceiver.isActiveAndEnabled)
        {
            stateMachine.ForceReceiver.enabled = true;
        }

        stateMachine.ForceReceiver.AddForce(jumpDir * stateMachine.JumpForce * 1.5f);
    }
}