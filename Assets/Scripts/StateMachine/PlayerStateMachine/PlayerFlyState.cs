using UnityEngine;

/// <summary>
/// Debug State: Player Fly State
/// - Only used on debug mode
/// - Player Fly to the desired position
/// </summary>
public class PlayerFlyState : PlayerBaseState
{
    
    public PlayerFlyState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    private float velocidad = 10f;

    public override void Enter()
    {
        stateMachine.ForceReceiver.enabled = false;
    }

    public override void Tick(float deltaTime)
    {
        // 1. Obtener direcci�n de la c�mara (solo en el plano horizontal XZ)
        Vector3 adelante = Camera.main.transform.forward;
        Vector3 derecha = Camera.main.transform.right;

        // Forzamos que no se muevan en el eje Y para que el movimiento sea plano
        adelante.y = 0;
        derecha.y = 0;
        adelante.Normalize();
        derecha.Normalize();

        // 2. Capturar inputs de WASD
        float h = Input.GetAxis("Horizontal"); // A, D
        float v = Input.GetAxis("Vertical");   // W, S

        // 3. Calcular direcci�n final de WASD
        Vector3 direccionFinal = (adelante * v) + (derecha * h);

        // 4. Anadir subir/bajar (Eje Y global)
        if (Input.GetKey(KeyCode.Space))
        {
            direccionFinal.y = 1f;
        }
        else if (Input.GetKey(KeyCode.LeftShift))
        {
            direccionFinal.y = -1f;
        }

        // 5. Aplicar el movimiento
        stateMachine.transform.Translate(direccionFinal * velocidad * Time.deltaTime, Space.World);
    }

    public override void Exit()
    {
        stateMachine.ForceReceiver.enabled = true;
    }
}
