using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class InputHandler : MonoBehaviour, InputSystem_Actions.IPlayerActions
{
    private InputSystem_Actions _controls;

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
    public event Action SwitchColorEvent;

    public static event Action OnPauseGameEvent;
    public static event Action<bool> OnInputDeviceChanged;
    public static event Action InteractionEvent;

    private void Start()
    {
        _controls = new InputSystem_Actions();
        _controls.Player.SetCallbacks(this);
        _controls.Player.Enable();
    }

    private void OnDestroy()
    {
        _controls.Player.Disable();
    }

    public void OnAttack(InputAction.CallbackContext context)
    {
        if (context.performed) IsFiring = true;
        else if (context.canceled) IsFiring = false;
    }

    public void OnInteract(InputAction.CallbackContext context)
    {
        if (context.started) InteractionEvent?.Invoke();
    }

    public void OnDive(InputAction.CallbackContext context)
    {
        if (!context.performed) return;
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

        bool wasUsingGamepad = IsUsingGamepad;

        if (context.control.device is Mouse)
            IsUsingGamepad = false;
        else if (context.control.device is Gamepad)
            IsUsingGamepad = true;

        if (wasUsingGamepad != IsUsingGamepad)
            OnInputDeviceChanged?.Invoke(IsUsingGamepad);
    }

    public void OnMove(InputAction.CallbackContext context)
    {
        MoveVector = context.ReadValue<Vector2>();
    }

    public void OnNext(InputAction.CallbackContext context) { }
    public void OnPrevious(InputAction.CallbackContext context) { }
    public void OnSprint(InputAction.CallbackContext context) { }

    public void OnAim(InputAction.CallbackContext context)
    {
        if (context.performed) isAiming = true;
        else if (context.canceled) isAiming = false;
    }

    public void OnDColorChange(InputAction.CallbackContext context)
    {
        if (context.performed) isDColorChange = true;
        else if (context.canceled) isDColorChange = false;
    }

    public void OnPauseGame(InputAction.CallbackContext context)
    {
        if (context.performed) OnPauseGameEvent?.Invoke();
    }

    public void OnColorAction(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            isColorActing = true;
            ColorActionEvent?.Invoke();
        }
        else if (context.canceled)
        {
            isColorActing = false;
        }
    }

    public void OnColorSwitch(InputAction.CallbackContext context)
    {
        if (!context.performed) return;
        SwitchColorEvent?.Invoke();
    }
}
