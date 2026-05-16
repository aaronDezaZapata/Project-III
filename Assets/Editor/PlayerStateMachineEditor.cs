using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(PlayerStateMachine))]
public class PlayerStateMachineEditor : Editor
{
    private PlayerStateMachine targetScript;

    private void OnEnable()
    {
        targetScript = (PlayerStateMachine)target;
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        
        EditorGUILayout.Space(10);
        DrawHeader("MAIN CONFIGURATION", Color.white);
        DrawBackingProperty("playerState");
        DrawBackingProperty("isOnEvent");

        EditorGUILayout.Space(5);
        DrawBackingProperty("InputReader");
        DrawBackingProperty("Controller");
        DrawBackingProperty("ForceReceiver");
        DrawBackingProperty("Animator");
        DrawBackingProperty("mainCamera");
        DrawBackingProperty("aimCamera");
        DrawBackingProperty("aimCameraPitchControl");
        DrawBackingProperty("MiceSensitivity");
        DrawBackingProperty("GamepadSensitivity");
        DrawBackingProperty("XAxisInverted");
        DrawBackingProperty("MiceAimSensitivity");
        DrawBackingProperty("GamepadAimSensitivity");
        DrawBackingProperty("AimXAxisInverted");
        DrawBackingProperty("Health");
        DrawBackingProperty("Mat_Player");
        
        EditorGUILayout.Space(10);
        DrawHeader("BASE MOVEMENT", Color.white);
        DrawBackingProperty("FreeLookMovementSpeed");
        DrawBackingProperty("AbsorbingMovementSpeed");
        DrawBackingProperty("RotationSpeed");
        DrawBackingProperty("DashDuration");
        DrawBackingProperty("DashLength");
        DrawBackingProperty("JumpForce");
        DrawBackingProperty("AccelerationTime");
        DrawBackingProperty("DecelerationTime");
        
        DrawBackingProperty("HasDoubleJump");
        DrawBackingProperty("DoubleJumpForce");
        
        DrawBackingProperty("CoyoteTime");
        DrawBackingProperty("ShadowDrop");
        
        EditorGUILayout.Space(10);
        DrawHeader("Ground Check", Color.white);
        DrawBackingProperty("groundCheckDistance");
        DrawBackingProperty("groundCheckRadius");
        DrawBackingProperty("groundMask");
        DrawBackingProperty("groundCheckOrigin");
        DrawBackingProperty("isGrounded");
        
        EditorGUILayout.Space(10);
        DrawHeader("Particles", Color.white);
        DrawBackingProperty("FootstepParticles1");
        DrawBackingProperty("FootstepParticles2");
        DrawBackingProperty("LandingParticles");
        DrawBackingProperty("MinFallVelocityToPlayLandingParticle");
        
        EditorGUILayout.Space(10);
        DrawHeader("SPLATOON & SHOOTING", Color.cyan);
        DrawBackingProperty("SwimSpeed");
        DrawBackingProperty("WallJumpForce");
        DrawBackingProperty("WallJumpAngle");
        DrawBackingProperty("InkDecalPrefab");
        DrawBackingProperty("InkLayer");
        DrawBackingProperty("GunOrigin");
        DrawBackingProperty("reticle");
        DrawBackingProperty("OriginalMesh");
        DrawBackingProperty("SharkFinMesh");
        
        DrawBackingProperty("FirePoint");
        DrawBackingProperty("ProjectilePrefab");
        DrawBackingProperty("FireCooldown");
        DrawBackingProperty("ReticleTransform");
        
        EditorGUILayout.Space(20);
        
        if (targetScript.playerState == PlayerStates.GREEN)
        {
            DrawHeader("--- GREEN STATE (GRAPPLE/WHIP) ---", Color.green);
            GUI.backgroundColor = new Color(0.7f, 1f, 0.7f); 
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            DrawBackingProperty("HasGreenAbility");
            DrawBackingProperty("MaxGrappleDistance");
            DrawBackingProperty("SwingRadius");
            DrawBackingProperty("MinSwingSpeed");
            DrawBackingProperty("SwingInputForce");
            DrawBackingProperty("GrappleJumpForce");
            DrawBackingProperty("GrappleObstacleLayer");
            DrawBackingProperty("GrappleRope");
            DrawBackingProperty("GrappleRopeOrigin");

            EditorGUILayout.Space(5);
            EditorGUILayout.LabelField("Whip Mechanics", EditorStyles.boldLabel);
            DrawBackingProperty("WhipObjectLayer");
            DrawBackingProperty("WhipThrowForceMin");
            DrawBackingProperty("WhipThrowForceMax");
            DrawBackingProperty("EnemyDetectionRange");
            DrawBackingProperty("WhipStartSpinSpeed");
            DrawBackingProperty("WhipSpinAcceleration");
            DrawBackingProperty("WhipMaxSpinSpeed");
            DrawBackingProperty("WhipHoldRadius");
            DrawBackingProperty("WhipHoldHeight");
            DrawBackingProperty("WhipCaptureSpeed");

            EditorGUILayout.EndVertical();
            GUI.backgroundColor = Color.white;
        }
        
        if (targetScript.playerState == PlayerStates.BLUE)
        {
            DrawHeader("--- BLUE STATE (GEYSER) ---", Color.blue);
            GUI.backgroundColor = new Color(0.6f, 0.8f, 1f);
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            
            DrawHeader("Force Variable Config", Color.white);
            DrawBackingProperty("GeyserCooldownTime");
            DrawBackingProperty("GeyserActivationTime");

            
            DrawHeader("Force Variable Config", Color.white);
            DrawBackingProperty("HoverForce");
            DrawBackingProperty("aerialMoveSpeed");
            
            DrawBackingProperty("Water_JetParticle");
            DrawBackingProperty("WaterGeyserParticle");
            DrawBackingProperty("WaterGeyserParticleSecond");

            EditorGUILayout.EndVertical();
            GUI.backgroundColor = Color.white;
        }
        
        serializedObject.ApplyModifiedProperties();
    }
    
    private void DrawHeader(string title, Color color)
    {
        GUIStyle style = new GUIStyle(EditorStyles.boldLabel);
        style.normal.textColor = color;
        
        if (color == Color.black && EditorGUIUtility.isProSkin) style.normal.textColor = Color.white;

        EditorGUILayout.LabelField(title, style);
        
        Rect rect = EditorGUILayout.GetControlRect(false, 1);
        EditorGUI.DrawRect(rect, color);
        EditorGUILayout.Space(5);
    }
    
    private void DrawBackingProperty(string propertyName)
    {
        SerializedProperty prop = serializedObject.FindProperty(propertyName);
        
        if (prop == null)
            prop = serializedObject.FindProperty($"<{propertyName}>k__BackingField");
        
        if (prop != null)
            EditorGUILayout.PropertyField(prop, new GUIContent(propertyName));
    }
}