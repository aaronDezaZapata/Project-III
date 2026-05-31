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
        DrawBackingProperty("isRestrictedToForwardBackward");
        DrawBackingProperty("eventForwardDirection");

        EditorGUILayout.Space(5);
        DrawBackingProperty("InputReader");
        DrawBackingProperty("Controller");
        DrawBackingProperty("ForceReceiver");
        DrawBackingProperty("Animator");
        DrawBackingProperty("PlayerAudio");
        DrawBackingProperty("MainCamera");
        DrawBackingProperty("AimCamera");
        DrawBackingProperty("AimCameraPitchControl");
        DrawBackingProperty("MatPlayer");
        DrawBackingProperty("OriginalMesh");
        DrawBackingProperty("SharkFinMesh");

        EditorGUILayout.Space(5);
        DrawHeader("Camera Sensitivity", Color.white);
        DrawBackingProperty("MiceSensitivity");
        DrawBackingProperty("GamepadSensitivity");
        DrawBackingProperty("MiceAimSensitivity");
        DrawBackingProperty("GamepadAimSensitivity");
        DrawBackingProperty("AimXAxisInverted");

        EditorGUILayout.Space(10);
        DrawHeader("BASE MOVEMENT", Color.white);
        DrawBackingProperty("FreeLookMovementSpeed");
        DrawBackingProperty("RotationSpeed");
        DrawBackingProperty("JumpForce");
        DrawBackingProperty("AccelerationTime");
        DrawBackingProperty("DecelerationTime");
        DrawBackingProperty("HasDoubleJump");
        DrawBackingProperty("DoubleJumpForce");
        DrawBackingProperty("CoyoteTime");

        EditorGUILayout.Space(5);
        DrawHeader("Direction Change Settings", Color.white);
        DrawBackingProperty("DirectionChangeThreshold");
        DrawBackingProperty("QuickStopTime");
        DrawBackingProperty("QuickStopSpeedThreshold");

        EditorGUILayout.Space(10);
        DrawHeader("Ground Check", Color.white);
        DrawBackingProperty("groundCheckDistance");
        DrawBackingProperty("groundCheckRadius");
        DrawBackingProperty("groundMask");
        DrawBackingProperty("groundCheckOrigin");
        DrawBackingProperty("slopeSlideSpeed");
        DrawBackingProperty("isGrounded");
        DrawBackingProperty("isOnSteepSlope");

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
        DrawBackingProperty("inkDecalPrefab");
        DrawBackingProperty("inkLayer");

        EditorGUILayout.Space(5);
        DrawHeader("Shooting Config", Color.white);
        DrawBackingProperty("FirePoint");
        DrawBackingProperty("ProjectilePrefab");
        DrawBackingProperty("FireCooldown");
        DrawBackingProperty("aimMovementSpeed");
        DrawBackingProperty("horizontalSensitivity");
        DrawBackingProperty("verticalSensitivity");
        DrawBackingProperty("minVerticalAngle");
        DrawBackingProperty("maxVerticalAngle");
        DrawBackingProperty("ReticleSurfaceOffset");
        DrawBackingProperty("WaterGeyserParticle");
        DrawBackingProperty("WaterGeyserParticleSecond");

        EditorGUILayout.Space(20);

        if (targetScript.playerState == PlayerStates.GREEN)
        {
            DrawHeader("--- GREEN STATE (GRAPPLE/WHIP) ---", Color.green);
            GUI.backgroundColor = new Color(0.7f, 1f, 0.7f);
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            DrawBackingProperty("MaxGrappleDistance");
            DrawBackingProperty("SwingRadius");
            DrawBackingProperty("MinSwingSpeed");
            DrawBackingProperty("SwingInputForce");
            DrawBackingProperty("GrappleJumpForce");
            DrawBackingProperty("GrappleObstacleLayer");
            DrawBackingProperty("GrappleRope");
            DrawBackingProperty("GrappleRopeOrigin");

            EditorGUILayout.EndVertical();
            GUI.backgroundColor = Color.white;
        }

        if (targetScript.playerState == PlayerStates.BLUE)
        {
            DrawHeader("--- BLUE STATE (GEYSER) ---", Color.blue);
            GUI.backgroundColor = new Color(0.6f, 0.8f, 1f);
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            DrawBackingProperty("GeyserCooldownTime");
            DrawBackingProperty("HoverForce");
            DrawBackingProperty("AerialMoveSpeed");

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
