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
        
        stateMachine.MainCamera.Priority = 10;

        originalHeight = stateMachine.Controller.height;
        originalCenter = stateMachine.Controller.center;
        
        stateMachine.Controller.height = 0.5f;
        stateMachine.Controller.center = new Vector3(0, 0.25f, 0);

        swimVelocity = Vector3.zero;
        timeWithoutInk = 0f;
        
        CameraManager.Instance.ChangeCameraSwimming(true);


        TogglePlayerMesh(true);

        stateMachine.PlayerAudio?.PlaySwimEnter();
        stateMachine.PlayerAudio?.StartSwimLoop();
    }

    public override void Tick(float deltaTime)
    {
        stateMachine.CheckForInk();
        stateMachine.ForceReceiver.enabled = false;

        
        if (!stateMachine._isOnInk)
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
        stateMachine.InputReader.DiveEvent -= OnDiveExit;
        stateMachine.InputReader.JumpEvent -= PerformInkJump;
        
        stateMachine.Controller.height = originalHeight;
        stateMachine.Controller.center = originalCenter;
        
        stateMachine.transform.rotation = Quaternion.FromToRotation(stateMachine.transform.up, Vector3.up) * stateMachine.transform.rotation;
        
        CameraManager.Instance.ChangeCameraSwimming(false);

        TogglePlayerMesh(false);
        stateMachine.PlayerAudio?.PlaySwimExit();
        stateMachine.PlayerAudio?.StopSwimLoop();
    }

    private void HandleSwimMovement(float deltaTime)
    {
        Vector2 input = stateMachine.InputReader.MoveVector;
        Vector3 surfaceNormal = stateMachine.currentInkNormal;

        Vector3 surfaceUp = Vector3.ProjectOnPlane(Vector3.up, surfaceNormal);
        if (surfaceUp.sqrMagnitude < 0.1f)
            surfaceUp = Vector3.ProjectOnPlane(Camera.main.transform.forward, surfaceNormal);
        surfaceUp = surfaceUp.normalized;

        Vector3 surfaceRight = Vector3.ProjectOnPlane(Camera.main.transform.right, surfaceNormal);
        if (surfaceRight.sqrMagnitude < 0.01f)
            surfaceRight = Vector3.Cross(surfaceNormal, surfaceUp);
        surfaceRight = surfaceRight.normalized;

        Vector3 moveDir = (surfaceUp * input.y + surfaceRight * input.x);
        if (moveDir.sqrMagnitude > 0.01f)
            moveDir.Normalize();
        else
            moveDir = Vector3.zero;

        // Bloquear si el destino no tiene tinta
        if (moveDir != Vector3.zero)
            moveDir = ClampToInkBoundary(moveDir, surfaceNormal, deltaTime);

        if (moveDir != Vector3.zero)
        {
            Quaternion targetRotation = Quaternion.LookRotation(moveDir, surfaceNormal);
            stateMachine.transform.rotation = Quaternion.Slerp(
                stateMachine.transform.rotation, targetRotation, deltaTime * 20f);
        }
        else
        {
            Quaternion targetRotation = Quaternion.FromToRotation(
                stateMachine.transform.up, surfaceNormal) * stateMachine.transform.rotation;
            stateMachine.transform.rotation = Quaternion.Slerp(
                stateMachine.transform.rotation, targetRotation, deltaTime * 10f);
        }

        if (moveDir.magnitude > 0.1f)
            swimVelocity = Vector3.MoveTowards(
                swimVelocity, moveDir * stateMachine.SwimSpeed, 60f * deltaTime);
        else
            swimVelocity = Vector3.MoveTowards(swimVelocity, Vector3.zero, 40f * deltaTime);

        bool hittingSideGeometry = (stateMachine.Controller.collisionFlags & CollisionFlags.Sides) != 0;
        Vector3 stickForce = hittingSideGeometry ? Vector3.zero : -surfaceNormal * 5f;

        stateMachine.Controller.Move((swimVelocity + stickForce) * deltaTime);
    }

    private Vector3 ClampToInkBoundary(Vector3 moveDir, Vector3 surfaceNormal, float deltaTime)
    {
        float lookahead = stateMachine.SwimSpeed * deltaTime * 6f;
        float checkOffset = 0.3f;

        // Punto adelante del jugador, ligeramente elevado sobre la superficie
        Vector3 futurePos = stateMachine.transform.position
                          + moveDir * lookahead
                          + surfaceNormal * checkOffset;

        // Raycast hacia la superficie para ver si hay tinta allí
        bool inkAhead = Physics.Raycast(
            futurePos,
            -surfaceNormal,
            out RaycastHit hit,
            checkOffset * 3f,
            stateMachine.inkLayer
        );

        // Hay tinta delante: movimiento libre
        if (inkAhead)
            return moveDir;

        // No hay tinta: intentar moverse solo en la dirección lateral (strafe)
        // Separamos moveDir en componente "hacia el borde" y componente lateral
        Vector3 boundaryNormal = Vector3.ProjectOnPlane(moveDir, surfaceNormal).normalized;
        Vector3 lateralDir = Vector3.Cross(surfaceNormal, boundaryNormal).normalized;

        // Conservamos cuánto del input original va en lateral
        float lateralAmount = Vector3.Dot(
            new Vector3(stateMachine.InputReader.MoveVector.x,
                        0,
                        stateMachine.InputReader.MoveVector.y),
            lateralDir
        );

        Vector3 lateralMove = lateralDir * lateralAmount;

        if (lateralMove.sqrMagnitude > 0.01f)
        {
            // Verificamos que la dirección lateral sí tenga tinta
            Vector3 lateralFuturePos = stateMachine.transform.position
                                     + lateralMove.normalized * lookahead
                                     + surfaceNormal * checkOffset;

            bool inkLateral = Physics.Raycast(
                lateralFuturePos,
                -surfaceNormal,
                checkOffset * 3f,
                stateMachine.inkLayer
            );

            if (inkLateral)
            {
                swimVelocity = Vector3.ProjectOnPlane(swimVelocity, boundaryNormal);
                return lateralMove.normalized;
            }
        }

        // Sin salida: frenar y parar
        swimVelocity = Vector3.MoveTowards(swimVelocity, Vector3.zero, 80f * deltaTime);
        return Vector3.zero;
    }
    private void PerformInkJump()
    {
        Vector3 surfaceNormal = stateMachine.currentInkNormal;
        
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