using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class InputHandler : MonoBehaviour, InputSystem_Actions.IPlayerActions
{
    InputSystem_Actions controls;
    

    public Vector2 MoveVector { get; private set; }
    public Vector2 LookVector { get; private set; }

    public bool isAiming { get; private set; }
    public bool IsFiring { get; private set; }
    public bool isHeiser { get; private set; }
    public bool isGreen { get; set; }

    public event Action JumpEvent;
    public event Action DashEvent;
    public event Action DiveEvent;
    public event Action InteractionEvent;

    void Start()
    {
        controls = new InputSystem_Actions();
        controls.Player.SetCallbacks(this);

        controls.Player.Enable();
    }


    void OnDestroy()
    {
        controls.Player.Disable();
    }

    

    public void OnAttack(InputAction.CallbackContext context)
    {
        if (context.performed)
        { IsFiring = true; }

        else if (context.canceled)
        { IsFiring = false; }
    }

    public void OnInteract(InputAction.CallbackContext context)
    {
        if (!context.performed) { InteractionEvent?.Invoke(); }
    }

    public void OnDive(InputAction.CallbackContext context)
    {
        if (!context.performed) { return; }
        DiveEvent?.Invoke();
    }

    public void OnJump(InputAction.CallbackContext context)
    {
        if (!context.performed) { return; }
        JumpEvent?.Invoke();
    }

    public void OnLook(InputAction.CallbackContext context)
    {
        LookVector = context.ReadValue<Vector2>();
    }

    public void OnMove(InputAction.CallbackContext context)
    {
        MoveVector = context.ReadValue<Vector2>();
    }

    public void OnNext(InputAction.CallbackContext context)
    {
        
    }

    public void OnPrevious(InputAction.CallbackContext context)
    {
        
    }

    public void OnSprint(InputAction.CallbackContext context)
    {
        
    }

    public void OnDash(InputAction.CallbackContext context)
    {
        if (!context.performed) { return; }
        DashEvent?.Invoke();
    }

    public void OnAim(InputAction.CallbackContext context)
    {

        if (context.performed)
            {isAiming = true;}
        
        else if (context.canceled)
            {isAiming = false;}


        Debug.Log("isAiming");

    }

    public void OnHeiser(InputAction.CallbackContext context)
    {
        if (context.performed)
        { isHeiser = true; }

        else if (context.canceled)
        { isHeiser = false; }
    }

    public void OnGreen(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            isGreen = true;
            Debug.Log("Green State Activated");
        }
        else if (context.canceled)
        {
            isGreen = false;
            Debug.Log("Green State Deactivated");
        }
    }


}
