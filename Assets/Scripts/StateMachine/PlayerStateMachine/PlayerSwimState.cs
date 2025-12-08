using UnityEngine;

public class PlayerSwimState : PlayerBaseState
{
    private float originalHeight;
    private Vector3 originalCenter;
    private Vector3 swimVelocity;

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
        // --- 1. ANULAR GRAVEDAD EXTERNA ---
        // Llamamos a Reset() CADA FRAME. Esto pone la verticalVelocity del ForceReceiver a 0.
        // Así el player no se cae de la pared.
        stateMachine.ForceReceiver.enabled = false;

        // --- 2. CHEQUEOS DE SALIDA ---
        if (!Input.GetKeyDown(KeyCode.N) || !stateMachine.IsOnInk)
        {
            // Pequeño empujón para no quedarse atrapado
            stateMachine.ForceReceiver.AddForce(stateMachine.transform.up * 2f);
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }

        if (Input.GetButtonDown("Jump"))
        {
            PerformInkJump();
            stateMachine.SwitchState(typeof(PlayerFreeLookState));
            return;
        }

        // --- 3. MOVIMIENTO ---
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

        // Calcular dirección basada en la cámara pero pegada a la superficie
        Vector3 cameraForward = Camera.main.transform.forward;
        Vector3 cameraRight = Camera.main.transform.right;

        Vector3 forwardProjected = Vector3.ProjectOnPlane(cameraForward, surfaceNormal).normalized;
        Vector3 rightProjected = Vector3.ProjectOnPlane(cameraRight, surfaceNormal).normalized;

        Vector3 moveDir = (forwardProjected * input.y + rightProjected * input.x).normalized;

        // --- ROTACIÓN (Clave para subir paredes) ---
        // Si nos movemos, rotamos para mirar hacia adelante, manteniendo los pies (up) en la normal
        if (moveDir != Vector3.zero)
        {
            Quaternion targetRotation = Quaternion.LookRotation(moveDir, surfaceNormal);
            // Rotación rápida para adaptarse a los cambios de 90 grados (suelo a pared)
            stateMachine.transform.rotation = Quaternion.Slerp(stateMachine.transform.rotation, targetRotation, deltaTime * 20f);
        }
        else
        {
            // Si estamos quietos, solo alineamos los pies con la normal (sin girar el cuerpo)
            Quaternion targetRotation = Quaternion.FromToRotation(stateMachine.transform.up, surfaceNormal) * stateMachine.transform.rotation;
            stateMachine.transform.rotation = Quaternion.Slerp(stateMachine.transform.rotation, targetRotation, deltaTime * 10f);
        }

        // --- MOVIMIENTO ---
        if (moveDir.magnitude > 0.1f)
        {
            swimVelocity = Vector3.MoveTowards(swimVelocity, moveDir * stateMachine.SwimSpeed, 60f * deltaTime);
        }
        else
        {
            swimVelocity = Vector3.MoveTowards(swimVelocity, Vector3.zero, 40f * deltaTime);
        }

        // --- GRAVEDAD DE ADHERENCIA ---
        // Empuje constante hacia la pared para que el CharacterController detecte colisión
        Vector3 stickForce = -surfaceNormal * 5f;

        // Aplicamos movimiento.
        // NOTA: NO sumamos stateMachine.ForceReceiver.Movement aquí porque lo reseteamos arriba.
        stateMachine.Controller.Move((swimVelocity + stickForce) * deltaTime);
    }

    private void PerformInkJump()
    {
        Vector3 jumpDir = stateMachine.CurrentInkNormal + (stateMachine.transform.forward * 0.5f);
        stateMachine.ForceReceiver.AddForce(jumpDir * stateMachine.JumpForce * 1.5f);
    }
}