using UnityEngine;

public class PlayerSwimState : PlayerBaseState
{
    private readonly int DiveAnim = Animator.StringToHash("Diving");
    private const float CrossFadeDuration = 0.1f;

    private float originalHeight;
    private Vector3 originalCenter;
    private Vector3 swimVelocity;
    private float timeWithoutInk = 0f;

    public PlayerSwimState(PlayerStateMachine stateMachine) : base(stateMachine)
    {
    }

    public override void Enter()
    {
        stateMachine.Animator.CrossFadeInFixedTime(DiveAnim, CrossFadeDuration);
        stateMachine.InputReader.DiveEvent += OnDiveExit;
        stateMachine.InputReader.JumpEvent += PerformInkJump;

        // Camera
        stateMachine.mainCamera.Priority = 10;

        originalHeight = stateMachine.Controller.height;
        originalCenter = stateMachine.Controller.center;

        // Forma de calamar
        stateMachine.Controller.height = 0.5f;
        stateMachine.Controller.center = new Vector3(0, 0.25f, 0);

        swimVelocity = Vector3.zero;
        timeWithoutInk = 0f;

        //Camera Pull Back
        CameraManager.Instance.ChangeCameraSwimming(true);


        TogglePlayerMesh(true);

        stateMachine.PlayerAudio?.PlaySwimEnter();
        stateMachine.PlayerAudio?.StartSwimLoop();
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
                OnDiveExit();
                return;
            }
        }
        else
        {
            timeWithoutInk = 0f;
        }
        
        HandleSwimMovement(deltaTime);
    }

    public override void Exit()
    {
        // Input Events
        stateMachine.InputReader.DiveEvent -= OnDiveExit;
        stateMachine.InputReader.JumpEvent -= PerformInkJump;
        
        stateMachine.Controller.height = originalHeight;
        stateMachine.Controller.center = originalCenter;

        // Al salir, rotamos suavemente hacia arriba global
        stateMachine.transform.rotation = Quaternion.FromToRotation(stateMachine.transform.up, Vector3.up) * stateMachine.transform.rotation;

        //Camera Pull Front
        CameraManager.Instance.ChangeCameraSwimming(false);

        // stateMachine.ForceReceiver.enabled = true;

        TogglePlayerMesh(false);
        stateMachine.PlayerAudio?.PlaySwimExit();
        stateMachine.PlayerAudio?.StopSwimLoop();
    }

    private void HandleSwimMovement(float deltaTime)
    {
        Vector2 input = stateMachine.InputReader.MoveVector;
        Vector3 surfaceNormal = stateMachine.CurrentInkNormal;

        // "Subir" en la superficie = world up proyectado sobre el plano de la tinta.
        // Esto hace que W siempre suba por paredes y S baje, independientemente de dónde mire la cámara.
        Vector3 surfaceUp = Vector3.ProjectOnPlane(Vector3.up, surfaceNormal);

        // Si la superficie es casi horizontal (suelo/techo), world up se colapsa → usamos camera forward
        if (surfaceUp.sqrMagnitude < 0.1f)
            surfaceUp = Vector3.ProjectOnPlane(Camera.main.transform.forward, surfaceNormal);

        surfaceUp = surfaceUp.normalized;

        // Eje lateral: camera right proyectado sobre el plano
        Vector3 surfaceRight = Vector3.ProjectOnPlane(Camera.main.transform.right, surfaceNormal);

        // Fallback si camera right es casi paralelo a la normal (colapsaría a cero)
        if (surfaceRight.sqrMagnitude < 0.01f)
            surfaceRight = Vector3.Cross(surfaceNormal, surfaceUp);

        surfaceRight = surfaceRight.normalized;

        // input.y → sube/baja por la superficie  |  input.x → izquierda/derecha
        Vector3 moveDir = (surfaceUp * input.y + surfaceRight * input.x);
        
        if (moveDir.sqrMagnitude > 0.01f)
        {
            moveDir.Normalize();
        }
        else
        {
            moveDir = Vector3.zero;
        }

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
        
        // Si el CharacterController ya está tocando geometría lateral (esquina, pared adyacente),
        // eliminamos el stickForce para que no quede encallado entre la tinta y esa geometría.
        bool hittingSideGeometry = (stateMachine.Controller.collisionFlags & CollisionFlags.Sides) != 0;
        Vector3 stickForce = hittingSideGeometry ? Vector3.zero : -surfaceNormal * 5f;

        stateMachine.Controller.Move((swimVelocity + stickForce) * deltaTime);
    }

    private void PerformInkJump()
    {
        Vector3 surfaceNormal = stateMachine.CurrentInkNormal;
        
        float surfaceAngle = Vector3.Angle(surfaceNormal, Vector3.up);
        
        bool isOnVerticalWall = surfaceAngle > 60f;
        
        Vector3 jumpDir;
        float jumpForce;
        
        if (isOnVerticalWall)
        {
            Vector3 outwardDir = surfaceNormal.normalized;
            Vector3 upwardDir = Vector3.up;
            
            float angleRad = stateMachine.WallJumpAngle * Mathf.Deg2Rad;
            float horizontalComponent = Mathf.Sin(angleRad);
            float verticalComponent = Mathf.Cos(angleRad);
            
            jumpDir = (outwardDir * horizontalComponent + upwardDir * verticalComponent).normalized;
            jumpForce = stateMachine.WallJumpForce;
            
        }
        else
        {
            Vector2 input = stateMachine.InputReader.MoveVector;
            
            if (input.magnitude > 0.1f)
            {
                Vector3 cameraRight = Camera.main.transform.right;
                Vector3 rightProjected = Vector3.ProjectOnPlane(cameraRight, surfaceNormal).normalized;
                Vector3 forwardProjected = Vector3.Cross(rightProjected, surfaceNormal);
                Vector3 moveDir = (forwardProjected * input.y + rightProjected * input.x).normalized;
                
                jumpDir = (surfaceNormal + moveDir * 0.5f).normalized;
            }
            else
            {
                jumpDir = surfaceNormal;
            }
            
            jumpForce = stateMachine.JumpForce * 1.5f;
        }
        
        if(!stateMachine.ForceReceiver.isActiveAndEnabled)
            stateMachine.ForceReceiver.enabled = true;
        
        stateMachine.ForceReceiver.AddForce(jumpDir * jumpForce);
        stateMachine.PlayerAudio?.PlaySwimBoost();

        OnDiveExit();
    }

    private void OnDiveExit()
    {
        if(!stateMachine.ForceReceiver.isActiveAndEnabled)
            stateMachine.ForceReceiver.enabled = true;
        stateMachine.ReturnToMainState();
    }

     public void TogglePlayerMesh(bool isLow)
    {
        if (stateMachine.OriginalMesh != null)
            stateMachine.OriginalMesh.SetActive(!isLow);
            
        if (stateMachine.SharkFinMesh != null)
            stateMachine.SharkFinMesh.SetActive(isLow);
    }
}