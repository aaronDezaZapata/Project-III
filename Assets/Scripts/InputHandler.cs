using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class InputHandler : MonoBehaviour, InputSystem_Actions.IPlayerActions
{
    InputSystem_Actions controls;

    public Vector2 MoveVector { get; private set; }
    public Vector2 LookVector { get; private set; }
    
    public bool IsUsingGamepad { get; private set; }

    public bool isAiming { get; private set; }
    public bool IsFiring { get; private set; }
    public bool isColorActing { get; private set; }
    
    public bool isDColorChange { get; private set; }
    public bool isJumpHeld { get; private set; }


    public event Action JumpEvent;
    public event Action ColorActionEvent;
    public event Action DiveEvent;
    public event Action InteractionEvent;
    public event Action SwitchColorEvent;

    // Static Events
    public static event Action<bool> OnAiming;
    public static event Action OnPauseGameEvent;
    public static event Action InteractionEvent;
    public static event Action OnPopUpEventCancel;

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
        if (context.performed)
        {
            isJumpHeld = true;
            JumpEvent?.Invoke();
        }
        else if (context.canceled)
        {
            isJumpHeld = false;
        }
    }

    public void OnLook(InputAction.CallbackContext context)
    {
        LookVector = context.ReadValue<Vector2>();
        
        // Detectar el dispositivo de entrada
        if (context.control.device is Mouse)
        {
            IsUsingGamepad = false;
        }
        else if (context.control.device is Gamepad)
        {
            IsUsingGamepad = true;
        }
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

    public void OnAim(InputAction.CallbackContext context)
    {
        if (context.performed)
        {isAiming = true;}
        
        else if (context.canceled)
        {isAiming = false;}
        
        OnAiming?.Invoke(isAiming);
    }

    
    public void OnDColorChange(InputAction.CallbackContext context)
    {
        if (context.performed)
        { isDColorChange = true; }

        else if (context.canceled)
        { isDColorChange = false; }
    }

    public void OnPauseGame(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            OnPauseGameEvent?.Invoke();            
        }
    }

    public void OnColorAction(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            isColorActing = true;
        }
        else if (context.canceled)
        {
            isColorActing = false;
        }
    }

    public void OnColorSwitch(InputAction.CallbackContext context)
    {
        if (!context.performed) { return; }
        SwitchColorEvent?.Invoke();
    }
}
