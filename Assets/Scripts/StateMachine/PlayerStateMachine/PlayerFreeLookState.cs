using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal.Internal;

public class PlayerFreeLookState : PlayerBaseState
{

    public PlayerFreeLookState(PlayerStateMachine stateMachine) : base(stateMachine)
    { 
       
    }


    public override void Enter()
    {
        stateMachine.InputReader.JumpEvent += OnJump;

        stateMachine.InputReader.DashEvent += OnDash;
    }

  

    public override void Tick(float deltaTime)
    {
        /*stateMachine.CheckForInk();
        if (Input.GetMouseButton(0))
        {
            stateMachine.ShootInk();
        }

      
        if (Input.GetKeyDown(KeyCode.B) && stateMachine.IsOnInk)
        {
            stateMachine.SwitchState(typeof(PlayerSwimState));
            return;
        }*/


        Vector3 movement = CalculateMovement();


       
        if (!Equals(movement, Vector3.zero))
        {
            FaceMovementDirection(movement, deltaTime);
        }

        Move(movement * stateMachine.FreeLookMovementSpeed, deltaTime);
    }

    public override void Exit()
    {

        stateMachine.InputReader.JumpEvent -= OnJump;

        stateMachine.InputReader.DashEvent -= OnDash;
    }

    private void FaceMovementDirection(Vector3 movement, float deltaTime)
    {
        stateMachine.transform.rotation = Quaternion.Lerp(
            stateMachine.transform.rotation,
            Quaternion.LookRotation(movement),
            deltaTime * stateMachine.RotationSpeed);
        
    }

    private void FaceMovementDirectionInstant(Vector3 movement)
    {
        stateMachine.transform.rotation = Quaternion.LookRotation(movement);
            

    }

    Vector3 CalculateMovement()
    {
        Vector3 forward = Camera.main.transform.forward;
        Vector3 right = Camera.main.transform.right;

        forward.y = 0f;
        right.y = 0f;

        forward.Normalize();
        right.Normalize();

        return forward * stateMachine.InputReader.MoveVector.y + right * stateMachine.InputReader.MoveVector.x;
    }



    private void OnDash()
    {
        if (stateMachine.InputReader.MoveVector == Vector2.zero) { return; }

       //stateMachine.SwitchState(PlayerDashingState);
    }


    private void OnJump()
    {
        Debug.Log("Jumping");
        Jump();
    }



  

}
