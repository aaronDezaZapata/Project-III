using UnityEngine;

public class PlayerFlyState : PlayerBaseState
{
    private float velocidad = 10f;
    public PlayerFlyState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        stateMachine.ForceReceiver.enabled = false;
    }

    public override void Tick(float deltaTime)
    {
        Vector3 adelante = Camera.main.transform.forward;
        Vector3 derecha = Camera.main.transform.right;
        
        adelante.y = 0;
        derecha.y = 0;
        adelante.Normalize();
        derecha.Normalize();
        
        float h = Input.GetAxis("Horizontal");
        float v = Input.GetAxis("Vertical");
        
        Vector3 direccionFinal = (adelante * v) + (derecha * h);
        
        if (Input.GetKey(KeyCode.Space))
        {
            direccionFinal.y = 1f;
        }
        else if (Input.GetKey(KeyCode.LeftShift))
        {
            direccionFinal.y = -1f;
        }
        
        stateMachine.transform.Translate(direccionFinal * (velocidad * Time.deltaTime), Space.World);
    }

    public override void Exit()
    {
        stateMachine.ForceReceiver.enabled = true;
    }
   
}
