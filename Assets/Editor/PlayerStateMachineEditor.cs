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

        // ESTADO PRINCIPAL
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
        DrawBackingProperty("MouseSensitivity");
        DrawBackingProperty("GamepadSensitivity");
        DrawBackingProperty("Health");
        DrawBackingProperty("Mat_Player");

        // MOVIMIENTO BASE 
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

        //Ground Check
        EditorGUILayout.Space(10);
        DrawHeader("Ground Check", Color.white);
        DrawBackingProperty("groundCheckDistance");
        DrawBackingProperty("groundCheckRadius");
        DrawBackingProperty("groundMask");
        DrawBackingProperty("groundCheckOrigin");
        DrawBackingProperty("isGrounded");

        // COMMON SPLATOON & SHOOTING
        EditorGUILayout.Space(10);
        DrawHeader("SPLATOON & SHOOTING", Color.cyan);
        DrawBackingProperty("SwimSpeed");
        DrawBackingProperty("WallJumpForce");
        DrawBackingProperty("WallJumpAngle");
        DrawBackingProperty("InkDecalPrefab");
        DrawBackingProperty("InkLayer");
        DrawBackingProperty("GunOrigin");
        DrawBackingProperty("reticle");

        // Referencias de disparo
        DrawBackingProperty("FirePoint");
        DrawBackingProperty("ProjectilePrefab");
        DrawBackingProperty("FireCooldown");
        DrawBackingProperty("ReticleTransform");

        // LOGICA CONDICIONAL POR COLOR
        EditorGUILayout.Space(20);

        //  GREEN LOGIC
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
            GUI.backgroundColor = Color.white; // Restaurar color
        }

        // BLUE LOGIC (HEISER)
        if (targetScript.playerState == PlayerStates.BLUE)
        {
            DrawHeader("--- BLUE STATE (HEISER) ---", Color.blue);
            GUI.backgroundColor = new Color(0.6f, 0.8f, 1f);
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            
            DrawHeader("Force Variable Config", Color.white);
            DrawBackingProperty("HeiserCooldownTime");
            DrawBackingProperty("HeiserActivationTime");

            
            DrawHeader("Force Variable Config", Color.white);
            DrawBackingProperty("HoverForce");
            DrawBackingProperty("aerialMoveSpeed");

            // Particles related to blue/water go here
            DrawBackingProperty("Water_JetParticle");
            DrawBackingProperty("WaterHeiserParticle");
            DrawBackingProperty("WaterHeiserParticleSecond");

            EditorGUILayout.EndVertical();
            GUI.backgroundColor = Color.white;
        }

        // TODO: Remove
        // No existe estado grey
        // GRAY LOGIC 
        /*if (targetScript.playerState == PlayerStates.GREY)
        {
            DrawHeader("--- GRAY STATE ---", Color.gray);
            GUI.backgroundColor = new Color(0.8f, 0.8f, 0.8f);
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            DrawBackingProperty("HasGrayAbility");
            DrawBackingProperty("AbsorbableLayer");
            DrawBackingProperty("GrayAbsorbRange");
            DrawBackingProperty("GrayAbsorbAngle");
            DrawBackingProperty("GrayAbsorbSpeed");
            DrawBackingProperty("GrayMaxSimultaneousAbsorb");
            DrawBackingProperty("GrayHoldHeight");
            DrawBackingProperty("GrayHoldDistance");
            DrawBackingProperty("GrayProjectileSpeedMultiplier");
            DrawBackingProperty("GrayAbsorbParticles");

            // Lista normal
            SerializedProperty listProp = serializedObject.FindProperty("absorbedObjects");
            EditorGUILayout.PropertyField(listProp, true);

            EditorGUILayout.EndVertical();
            GUI.backgroundColor = Color.white;
        }*/

        // BLACK LOGIC
        if (targetScript.playerState == PlayerStates.BLACK)
        {
            DrawHeader("--- BLACK STATE ---", Color.black);
            GUI.backgroundColor = new Color(0.4f, 0.4f, 0.4f); // Gris oscuro
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            
            DrawBackingProperty("HasDashAttack");
            DrawBackingProperty("DashAttackSpeed");
            DrawBackingProperty("DashAttackMaxRange");
            DrawBackingProperty("DashAttackCollisionRadius");
            DrawBackingProperty("DashAttackKnockbackForce");
            DrawBackingProperty("DashAttackVerticalKnockback");
            DrawBackingProperty("DashAttackDamage");

            EditorGUILayout.EndVertical();
            GUI.backgroundColor = Color.white;
        }

        serializedObject.ApplyModifiedProperties();
    }

    // HELPER FUNCTIONS

    //header con color
    private void DrawHeader(string title, Color color)
    {
        GUIStyle style = new GUIStyle(EditorStyles.boldLabel);
        style.normal.textColor = color;
        // Si el color es negro uso blanco para que se lea en Unity, o negro en clara.
        if (color == Color.black && EditorGUIUtility.isProSkin) style.normal.textColor = Color.white;

        EditorGUILayout.LabelField(title, style);

        // Linea separadora coloreada
        Rect rect = EditorGUILayout.GetControlRect(false, 1);
        EditorGUI.DrawRect(rect, color);
        EditorGUILayout.Space(5);
    }

    // Busca propiedades generadas por "field: SerializeField" (<Nombre>k__BackingField)
    private void DrawBackingProperty(string propertyName)
    {
        // Intentamos buscar la propiedad con el nombre exacto (por si cambias a variables normales)
        SerializedProperty prop = serializedObject.FindProperty(propertyName);

        // Si es null, buscamos el formato de backing field autom�tico
        if (prop == null)
        {
            prop = serializedObject.FindProperty($"<{propertyName}>k__BackingField");
        }

        if (prop != null)
        {
            EditorGUILayout.PropertyField(prop, new GUIContent(propertyName));
        }
        else
        {
            // Avisar si no encuentra algo 
            // EditorGUILayout.LabelField($"Error: {propertyName} not found", EditorStyles.miniLabel);
        }
    }
}