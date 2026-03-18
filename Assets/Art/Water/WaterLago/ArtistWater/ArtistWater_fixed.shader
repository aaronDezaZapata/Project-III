Shader "Shader Graphs/Water"
{
    Properties
    {
        _Depth("Depth", Float) = 0
        _DepthFallOff("DepthFallOff", Float) = 0
        _MainColor("MainColor", Color) = (0, 0, 0, 0)
        _ShoreColor("ShoreColor", Color) = (0, 0, 0, 0)
        _FoamShoreWidth("FoamShoreWidth", Float) = 0
        _FoamColor("FoamColor", Color) = (0, 0, 0, 0)
        _SecondFoamWidth("SecondFoamWidth", Float) = 0.3
        [HDR]_SecondFoamColor("SecondFoamColor", Color) = (1, 1, 0, 1)
        [NoScaleOffset]_FoamTexture("FoamTexture", 2D) = "white" {}
        _FoamDepth("FoamDepth", Float) = 0
        _FoamFallOff("FoamFallOff", Float) = 0
        _FoamTiling("FoamTiling", Float) = 0
        _FoamSpeed("FoamSpeed", Vector) = (0, 0, 0, 0)
        _FoamAmount("FoamAmount", Float) = 0
        _FoamCutOut("FoamCutOut", Float) = 0
        [NoScaleOffset]_CausticTexture("CausticTexture", 2D) = "white" {}
        _CausticCutOut("CausticCutOut", Float) = 0
        [HDR]_CausticColor("CausticColor", Color) = (0, 0, 0, 0)
        _CausticsTiling("CausticsTiling", Float) = 1
        _CausticsSpeed("CausticsSpeed", Float) = 1
        _WaveIntensity("WaveIntensity", Float) = 0
        _WaveSpeed("WaveSpeed", Float) = 0
        _FlowSpeed("FlowSpeed", Float) = 0
        _FlowStrength("FlowStrength", Float) = 0
        [NoScaleOffset]_FlowMap("FlowMap", 2D) = "white" {}
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        #define REQUIRE_DEPTH_TEXTURE


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 texCoord0 : INTERP6;
             float4 fogFactorAndVertexLight : INTERP7;
             float3 positionWS : INTERP8;
             float3 normalWS : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Depth;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
        float _SecondFoamWidth;
        float4 _SecondFoamColor;
        float4 _FoamTexture_TexelSize;
        float _FoamDepth;
        float _FoamFallOff;
        float _FoamTiling;
        float2 _FoamSpeed;
        float _FoamAmount;
        float _FoamCutOut;
        float4 _CausticTexture_TexelSize;
        float _CausticCutOut;
        float4 _CausticColor;
        float _CausticsTiling;
        float _CausticsSpeed;
        float _WaveIntensity;
        float _WaveSpeed;
        float _FlowSpeed;
        float _FlowStrength;
        float4 _FlowMap_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END


        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FoamTexture);
        SAMPLER(sampler_FoamTexture);
        TEXTURE2D(_CausticTexture);
        SAMPLER(sampler_CausticTexture);
        TEXTURE2D(_FlowMap);
        SAMPLER(sampler_FlowMap);

        // Graph Includes
        // GraphIncludes: <None>

        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

        // Graph Functions

        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }

        // unity-custom-func-begin
        void FlowUV_float(float FlowSpeed, float Time, float2 UV, float2 FlowVector, out float2 UV1, out float2 UV2, out float Blend){
        float phase0 = Time * FlowSpeed - floor(Time * FlowSpeed);
        float phase1 = (Time * FlowSpeed + 0.5) - floor(Time * FlowSpeed + 0.5);

        UV1 = UV - FlowVector * phase0;
        UV2 = UV - FlowVector * phase1;

        Blend = abs((phase0 - 0.5) * 2.0);
        }
        // unity-custom-func-end

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        struct Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float
        {
        half4 uv0;
        float3 TimeParameters;
        };

        void SG_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float(float _FlowSpeed, float _FlowStrength, UnityTexture2D _FlowMap, UnityTexture2D _WaterTexture, Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float IN, out float4 UV2_2)
        {
        UnityTexture2D _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D = _WaterTexture;
        float _Property_d98c376d1ee546138072a488daec8b4c_Out_0_Float = _FlowSpeed;
        float4 _UV_bf331151e19d4743ac71b3a059904a4a_Out_0_Vector4 = IN.uv0;
        UnityTexture2D _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D = _FlowMap;
        float4 _UV_c10f5674a32049da84c46a321ffdfb6d_Out_0_Vector4 = IN.uv0;
        float4 _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.tex, _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.samplerstate, _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.GetTransformedUV((_UV_c10f5674a32049da84c46a321ffdfb6d_Out_0_Vector4.xy)) );
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_R_4_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.r;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_G_5_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.g;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_B_6_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.b;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_A_7_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.a;
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_R_1_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[0];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_G_2_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[1];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_B_3_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[2];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_A_4_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[3];
        float _Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float;
        Unity_Remap_float(_Split_6adf8f8dbcff4b98af7d114ecc255d36_G_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float);
        float _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float;
        Unity_Remap_float(_Split_6adf8f8dbcff4b98af7d114ecc255d36_R_1_Float, float2 (0, 1), float2 (-1, 1), _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float);
        float2 _Vector2_f223a963e73e447b88759a8aeaf7da92_Out_0_Vector2 = float2(_Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float, _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float);
        float _Property_8027a7e0aa194e549b8cd3e1219acce4_Out_0_Float = _FlowStrength;
        float2 _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_f223a963e73e447b88759a8aeaf7da92_Out_0_Vector2, (_Property_8027a7e0aa194e549b8cd3e1219acce4_Out_0_Float.xx), _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2);
        float2 _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2;
        float2 _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2;
        float _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float;
        FlowUV_float(_Property_d98c376d1ee546138072a488daec8b4c_Out_0_Float, IN.TimeParameters.x, (_UV_bf331151e19d4743ac71b3a059904a4a_Out_0_Vector4.xy), _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float);
        float4 _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.tex, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.samplerstate, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.GetTransformedUV(_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2) );
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_R_4_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.r;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_G_5_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.g;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_B_6_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.b;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_A_7_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.a;
        float4 _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.tex, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.samplerstate, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.GetTransformedUV(_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2) );
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_R_4_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.r;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_G_5_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.g;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_B_6_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.b;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_A_7_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.a;
        float4 _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4;
        Unity_Lerp_float4(_SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4, _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4, (_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float.xxxx), _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4);
        UV2_2 = _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        struct Bindings_DepthFade_fd37366848b771042941ee5121343adf_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };

        void SG_DepthFade_fd37366848b771042941ee5121343adf_float(float _Depth, float _DepthFallOff, Bindings_DepthFade_fd37366848b771042941ee5121343adf_float IN, out float OutVector1_1)
        {
        float _SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float);
        float4 _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_4283d983846047c3931269c4f290d4f9_R_1_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[0];
        float _Split_4283d983846047c3931269c4f290d4f9_G_2_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[1];
        float _Split_4283d983846047c3931269c4f290d4f9_B_3_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[2];
        float _Split_4283d983846047c3931269c4f290d4f9_A_4_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[3];
        float _Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float, _Split_4283d983846047c3931269c4f290d4f9_A_4_Float, _Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float);
        float _Property_2376aa4d3f03452fb19c1b6fe12cdd9d_Out_0_Float = _Depth;
        float _Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float;
        Unity_Divide_float(_Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float, _Property_2376aa4d3f03452fb19c1b6fe12cdd9d_Out_0_Float, _Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float);
        float _OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float;
        Unity_OneMinus_float(_Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float, _OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float);
        float _Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float;
        Unity_Saturate_float(_OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float, _Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float);
        float _Property_9c8e44da412b47a8a20d93b3cf08bd70_Out_0_Float = _DepthFallOff;
        float _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float;
        Unity_Maximum_float(_Property_9c8e44da412b47a8a20d93b3cf08bd70_Out_0_Float, float(0.005), _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float);
        float _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float;
        Unity_Power_float(_Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float, _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float, _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float);
        OutVector1_1 = _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float;
        }

        void Unity_Ceiling_float(float In, out float Out)
        {
            Out = ceil(In);
        }

        struct Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float
        {
        };

        void SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(float _Input, float _Alpha, Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float IN, out float Output_0)
        {
        float _Property_ca30cb36add94aabaa9d9dabfda56c02_Out_0_Float = _Input;
        float _Property_d3832a99da2f48919b2e31df6ee1452a_Out_0_Float = _Alpha;
        float _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float;
        Unity_Saturate_float(_Property_d3832a99da2f48919b2e31df6ee1452a_Out_0_Float, _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float);
        float _Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float;
        Unity_Subtract_float(_Property_ca30cb36add94aabaa9d9dabfda56c02_Out_0_Float, _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float, _Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float);
        float _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float;
        Unity_Ceiling_float(_Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float, _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float);
        Output_0 = _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float = _WaveIntensity;
            float3 _Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3 = float3(float(0), _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float, float(0));
            float _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float = _WaveSpeed;
            float _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float, _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float);
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_A_4_Float = 0;
            float _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float;
            Unity_Add_float(_Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float, _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float);
            float _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float;
            Unity_Add_float(_Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float, _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float);
            float _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float;
            Unity_Sine_float(_Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float, _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float);
            float3 _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3, (_Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float.xxx), _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3);
            float3 _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3, _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3);
            description.Position = _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_622f4b00a9ea415788676ffe06990d8e_Out_0_Float = _FlowSpeed;
            float _Property_d81dfb1a7514478f9e84e798877f387f_Out_0_Float = _FlowStrength;
            UnityTexture2D _Property_6f00f50a994a4340bbecb9a1603af3bd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FlowMap);
            UnityTexture2D _Property_3edce890842648a893430eea92089e01_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd;
            _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd.uv0 = IN.uv0;
            _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd.TimeParameters = IN.TimeParameters;
            float4 _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4;
            SG_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float(_Property_622f4b00a9ea415788676ffe06990d8e_Out_0_Float, _Property_d81dfb1a7514478f9e84e798877f387f_Out_0_Float, _Property_6f00f50a994a4340bbecb9a1603af3bd_Out_0_Texture2D, _Property_3edce890842648a893430eea92089e01_Out_0_Texture2D, _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd, _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4);
            float4 _Property_6621c89d7b3041c98c7849814df9ca18_Out_0_Vector4 = _FoamColor;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_360d81065f0a4a859a99f08b7011f10a;
            _DepthFade_360d81065f0a4a859a99f08b7011f10a.ScreenPosition = IN.ScreenPosition;
            _DepthFade_360d81065f0a4a859a99f08b7011f10a.NDCPosition = IN.NDCPosition;
            float _DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_360d81065f0a4a859a99f08b7011f10a, _DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float);
            float _Property_e743d6a6031845bebcd1b79a88ad2246_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_32f30c928e1b4a37ae49ec0875a29f14;
            float _CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float, _Property_e743d6a6031845bebcd1b79a88ad2246_Out_0_Float, _CutOut_32f30c928e1b4a37ae49ec0875a29f14, _CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float);
            UnityTexture2D _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_92eacbf2f91648cdb680cb07b4c84d83_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_c854dcb8c14345c08ccf253c400d0e82_Out_0_Float = _FoamTiling;
            float2 _Property_c0d69e7204734c43812eddc139c336c5_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c0d69e7204734c43812eddc139c336c5_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2);
            float2 _TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_92eacbf2f91648cdb680cb07b4c84d83_Out_1_Vector2, (_Property_c854dcb8c14345c08ccf253c400d0e82_Out_0_Float.xx), _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2, _TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2);
            float4 _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.tex, _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.samplerstate, _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2) );
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_R_4_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.r;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_G_5_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.g;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_B_6_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.b;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_A_7_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.a;
            float _Property_a30767ada2554636b433757722d925a5_Out_0_Float = _FoamDepth;
            float _Property_85a722b2d97c4696b06bd34d41768fc0_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_8253d0b28799460d91b86aaa80bda820;
            _DepthFade_8253d0b28799460d91b86aaa80bda820.ScreenPosition = IN.ScreenPosition;
            _DepthFade_8253d0b28799460d91b86aaa80bda820.NDCPosition = IN.NDCPosition;
            float _DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_a30767ada2554636b433757722d925a5_Out_0_Float, _Property_85a722b2d97c4696b06bd34d41768fc0_Out_0_Float, _DepthFade_8253d0b28799460d91b86aaa80bda820, _DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float);
            float4 _Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4, (_DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float.xxxx), _Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4);
            float _Property_e84b809010eb4099a84f1fe170e78493_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_24054a506ba44d258a9324359f9ab56c;
            float _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4).x, _Property_e84b809010eb4099a84f1fe170e78493_Out_0_Float, _CutOut_24054a506ba44d258a9324359f9ab56c, _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float);
            float _Add_3152088544f14edd9b579a71529e5eab_Out_2_Float;
            Unity_Add_float(_CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float, _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float, _Add_3152088544f14edd9b579a71529e5eab_Out_2_Float);
            float _Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float;
            Unity_Saturate_float(_Add_3152088544f14edd9b579a71529e5eab_Out_2_Float, _Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float);
            float4 _Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_6621c89d7b3041c98c7849814df9ca18_Out_0_Vector4, (_Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float.xxxx), _Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4);
            float4 _Property_92817ffb792e498491a70743808f9fb4_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_3f698ea5418d4b8a912b10d83ed0ddaf_Out_0_Float = _CausticsTiling;
            float _Property_036faa83e6af4cffb09d74a3bce4b1d4_Out_0_Float = _CausticsSpeed;
            float _Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float;
            Unity_Multiply_float_float(_Property_036faa83e6af4cffb09d74a3bce4b1d4_Out_0_Float, IN.TimeParameters.x, _Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float);
            float2 _TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3f698ea5418d4b8a912b10d83ed0ddaf_Out_0_Float.xx), (_Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float.xx), _TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2);
            float4 _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.tex, _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.samplerstate, _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2) );
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_R_4_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.r;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_G_5_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.g;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_B_6_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.b;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_A_7_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.a;
            UnityTexture2D _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_ae261fa440f7445f9680d4786d9e8d6c_Out_0_Float = _CausticsTiling;
            float _Property_d46424b6f49948c48d8aa5a54e86ab37_Out_0_Float = _CausticsSpeed;
            float _Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float;
            Unity_Multiply_float_float(_Property_d46424b6f49948c48d8aa5a54e86ab37_Out_0_Float, IN.TimeParameters.x, _Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float);
            float _Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float, -1, _Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float);
            float2 _TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_ae261fa440f7445f9680d4786d9e8d6c_Out_0_Float.xx), (_Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float.xx), _TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2);
            float4 _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.tex, _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.samplerstate, _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2) );
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_R_4_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.r;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_G_5_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.g;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_B_6_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.b;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_A_7_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.a;
            float4 _Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4, _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4, _Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4);
            float _Property_ea45466b5ff042dd9d72e0cb76d96729_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dd8e2a36eea948e9b85e89c106e39db9;
            float _CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4).x, _Property_ea45466b5ff042dd9d72e0cb76d96729_Out_0_Float, _CutOut_dd8e2a36eea948e9b85e89c106e39db9, _CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float);
            float4 _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_92817ffb792e498491a70743808f9fb4_Out_0_Vector4, (_CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float.xxxx), _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4);
            float4 _Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4;
            Unity_Add_float4(_Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4, _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4, _Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4);
            float _OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float;
            Unity_OneMinus_float(_Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float, _OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float);
            float _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float;
            Unity_OneMinus_float(_CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float, _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float);
            float _Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float;
            Unity_Add_float(_OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float, _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float, _Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float);
            float4 _Property_160f368928724737bd8d235406114282_Out_0_Vector4 = _ShoreColor;
            float _Property_1d8e92e9cd9d411ba17bf254d5c0ac2e_Out_0_Float = _Depth;
            float _Property_a2f1df831feb4ce7a481ba10d6dd5d6e_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7;
            _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7.ScreenPosition = IN.ScreenPosition;
            _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7.NDCPosition = IN.NDCPosition;
            float _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_1d8e92e9cd9d411ba17bf254d5c0ac2e_Out_0_Float, _Property_a2f1df831feb4ce7a481ba10d6dd5d6e_Out_0_Float, _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7, _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float);
            float4 _Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_160f368928724737bd8d235406114282_Out_0_Vector4, (_DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float.xxxx), _Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4);
            float _OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float, _OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float);
            float4 _Property_69288d55badb4bc4a9132d27bf2ecfe6_Out_0_Vector4 = _MainColor;
            float4 _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float.xxxx), _Property_69288d55badb4bc4a9132d27bf2ecfe6_Out_0_Vector4, _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4);
            float4 _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4;
            Unity_Add_float4(_Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4, _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4, _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4);
            float4 _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float.xxxx), _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4, _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4);
            float4 _Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4;
            Unity_Add_float4(_Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4, _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4, _Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4);
            // Second foam ring using Step (hard edge, cartoon style)
            float _SecondFoamTotalWidth = _FoamShoreWidth + _SecondFoamWidth;
            float _DepthFadeShore_SecondFoam;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_360d81065f0a4a859a99f08b7011f10a, _DepthFadeShore_SecondFoam);
            float _Step_SecondFoamOuter = step(_DepthFadeShore_SecondFoam, _SecondFoamTotalWidth);
            float _Step_SecondFoamInner = step(_DepthFadeShore_SecondFoam, _FoamShoreWidth);
            float _SecondFoamMask = saturate(_Step_SecondFoamOuter - _Step_SecondFoamInner);
            float4 _SecondFoamColorValue = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;

            // Lerp: donde hay segundo foam tapa completamente al primero, sin mezcla aditiva
            float4 _Add_WithSecondFoam = lerp(_Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4, _SecondFoamColorValue, _SecondFoamMask);

            float4 _Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4;
            Unity_Add_float4(_FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4, _Add_WithSecondFoam, _Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4);
            surface.BaseColor = (_Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Smoothness = float(0.5);
            surface.Occlusion = float(1);
            surface.Alpha = float(1);
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif

            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif





            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);

            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif

            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;

            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
        }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif

        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        #define REQUIRE_DEPTH_TEXTURE


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 texCoord0 : INTERP6;
             float4 fogFactorAndVertexLight : INTERP7;
             float3 positionWS : INTERP8;
             float3 normalWS : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Depth;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
        float _SecondFoamWidth;
        float4 _SecondFoamColor;
        float4 _FoamTexture_TexelSize;
        float _FoamDepth;
        float _FoamFallOff;
        float _FoamTiling;
        float2 _FoamSpeed;
        float _FoamAmount;
        float _FoamCutOut;
        float4 _CausticTexture_TexelSize;
        float _CausticCutOut;
        float4 _CausticColor;
        float _CausticsTiling;
        float _CausticsSpeed;
        float _WaveIntensity;
        float _WaveSpeed;
        float _FlowSpeed;
        float _FlowStrength;
        float4 _FlowMap_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END


        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FoamTexture);
        SAMPLER(sampler_FoamTexture);
        TEXTURE2D(_CausticTexture);
        SAMPLER(sampler_CausticTexture);
        TEXTURE2D(_FlowMap);
        SAMPLER(sampler_FlowMap);

        // Graph Includes
        // GraphIncludes: <None>

        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

        // Graph Functions

        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }

        // unity-custom-func-begin
        void FlowUV_float(float FlowSpeed, float Time, float2 UV, float2 FlowVector, out float2 UV1, out float2 UV2, out float Blend){
        float phase0 = Time * FlowSpeed - floor(Time * FlowSpeed);
        float phase1 = (Time * FlowSpeed + 0.5) - floor(Time * FlowSpeed + 0.5);

        UV1 = UV - FlowVector * phase0;
        UV2 = UV - FlowVector * phase1;

        Blend = abs((phase0 - 0.5) * 2.0);
        }
        // unity-custom-func-end

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        struct Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float
        {
        half4 uv0;
        float3 TimeParameters;
        };

        void SG_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float(float _FlowSpeed, float _FlowStrength, UnityTexture2D _FlowMap, UnityTexture2D _WaterTexture, Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float IN, out float4 UV2_2)
        {
        UnityTexture2D _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D = _WaterTexture;
        float _Property_d98c376d1ee546138072a488daec8b4c_Out_0_Float = _FlowSpeed;
        float4 _UV_bf331151e19d4743ac71b3a059904a4a_Out_0_Vector4 = IN.uv0;
        UnityTexture2D _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D = _FlowMap;
        float4 _UV_c10f5674a32049da84c46a321ffdfb6d_Out_0_Vector4 = IN.uv0;
        float4 _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.tex, _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.samplerstate, _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.GetTransformedUV((_UV_c10f5674a32049da84c46a321ffdfb6d_Out_0_Vector4.xy)) );
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_R_4_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.r;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_G_5_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.g;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_B_6_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.b;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_A_7_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.a;
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_R_1_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[0];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_G_2_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[1];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_B_3_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[2];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_A_4_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[3];
        float _Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float;
        Unity_Remap_float(_Split_6adf8f8dbcff4b98af7d114ecc255d36_G_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float);
        float _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float;
        Unity_Remap_float(_Split_6adf8f8dbcff4b98af7d114ecc255d36_R_1_Float, float2 (0, 1), float2 (-1, 1), _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float);
        float2 _Vector2_f223a963e73e447b88759a8aeaf7da92_Out_0_Vector2 = float2(_Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float, _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float);
        float _Property_8027a7e0aa194e549b8cd3e1219acce4_Out_0_Float = _FlowStrength;
        float2 _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_f223a963e73e447b88759a8aeaf7da92_Out_0_Vector2, (_Property_8027a7e0aa194e549b8cd3e1219acce4_Out_0_Float.xx), _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2);
        float2 _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2;
        float2 _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2;
        float _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float;
        FlowUV_float(_Property_d98c376d1ee546138072a488daec8b4c_Out_0_Float, IN.TimeParameters.x, (_UV_bf331151e19d4743ac71b3a059904a4a_Out_0_Vector4.xy), _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float);
        float4 _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.tex, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.samplerstate, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.GetTransformedUV(_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2) );
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_R_4_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.r;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_G_5_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.g;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_B_6_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.b;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_A_7_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.a;
        float4 _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.tex, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.samplerstate, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.GetTransformedUV(_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2) );
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_R_4_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.r;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_G_5_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.g;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_B_6_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.b;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_A_7_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.a;
        float4 _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4;
        Unity_Lerp_float4(_SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4, _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4, (_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float.xxxx), _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4);
        UV2_2 = _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        struct Bindings_DepthFade_fd37366848b771042941ee5121343adf_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };

        void SG_DepthFade_fd37366848b771042941ee5121343adf_float(float _Depth, float _DepthFallOff, Bindings_DepthFade_fd37366848b771042941ee5121343adf_float IN, out float OutVector1_1)
        {
        float _SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float);
        float4 _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_4283d983846047c3931269c4f290d4f9_R_1_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[0];
        float _Split_4283d983846047c3931269c4f290d4f9_G_2_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[1];
        float _Split_4283d983846047c3931269c4f290d4f9_B_3_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[2];
        float _Split_4283d983846047c3931269c4f290d4f9_A_4_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[3];
        float _Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float, _Split_4283d983846047c3931269c4f290d4f9_A_4_Float, _Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float);
        float _Property_2376aa4d3f03452fb19c1b6fe12cdd9d_Out_0_Float = _Depth;
        float _Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float;
        Unity_Divide_float(_Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float, _Property_2376aa4d3f03452fb19c1b6fe12cdd9d_Out_0_Float, _Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float);
        float _OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float;
        Unity_OneMinus_float(_Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float, _OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float);
        float _Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float;
        Unity_Saturate_float(_OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float, _Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float);
        float _Property_9c8e44da412b47a8a20d93b3cf08bd70_Out_0_Float = _DepthFallOff;
        float _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float;
        Unity_Maximum_float(_Property_9c8e44da412b47a8a20d93b3cf08bd70_Out_0_Float, float(0.005), _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float);
        float _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float;
        Unity_Power_float(_Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float, _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float, _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float);
        OutVector1_1 = _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float;
        }

        void Unity_Ceiling_float(float In, out float Out)
        {
            Out = ceil(In);
        }

        struct Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float
        {
        };

        void SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(float _Input, float _Alpha, Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float IN, out float Output_0)
        {
        float _Property_ca30cb36add94aabaa9d9dabfda56c02_Out_0_Float = _Input;
        float _Property_d3832a99da2f48919b2e31df6ee1452a_Out_0_Float = _Alpha;
        float _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float;
        Unity_Saturate_float(_Property_d3832a99da2f48919b2e31df6ee1452a_Out_0_Float, _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float);
        float _Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float;
        Unity_Subtract_float(_Property_ca30cb36add94aabaa9d9dabfda56c02_Out_0_Float, _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float, _Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float);
        float _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float;
        Unity_Ceiling_float(_Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float, _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float);
        Output_0 = _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float = _WaveIntensity;
            float3 _Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3 = float3(float(0), _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float, float(0));
            float _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float = _WaveSpeed;
            float _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float, _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float);
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_A_4_Float = 0;
            float _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float;
            Unity_Add_float(_Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float, _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float);
            float _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float;
            Unity_Add_float(_Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float, _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float);
            float _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float;
            Unity_Sine_float(_Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float, _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float);
            float3 _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3, (_Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float.xxx), _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3);
            float3 _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3, _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3);
            description.Position = _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_622f4b00a9ea415788676ffe06990d8e_Out_0_Float = _FlowSpeed;
            float _Property_d81dfb1a7514478f9e84e798877f387f_Out_0_Float = _FlowStrength;
            UnityTexture2D _Property_6f00f50a994a4340bbecb9a1603af3bd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FlowMap);
            UnityTexture2D _Property_3edce890842648a893430eea92089e01_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd;
            _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd.uv0 = IN.uv0;
            _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd.TimeParameters = IN.TimeParameters;
            float4 _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4;
            SG_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float(_Property_622f4b00a9ea415788676ffe06990d8e_Out_0_Float, _Property_d81dfb1a7514478f9e84e798877f387f_Out_0_Float, _Property_6f00f50a994a4340bbecb9a1603af3bd_Out_0_Texture2D, _Property_3edce890842648a893430eea92089e01_Out_0_Texture2D, _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd, _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4);
            float4 _Property_6621c89d7b3041c98c7849814df9ca18_Out_0_Vector4 = _FoamColor;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_360d81065f0a4a859a99f08b7011f10a;
            _DepthFade_360d81065f0a4a859a99f08b7011f10a.ScreenPosition = IN.ScreenPosition;
            _DepthFade_360d81065f0a4a859a99f08b7011f10a.NDCPosition = IN.NDCPosition;
            float _DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_360d81065f0a4a859a99f08b7011f10a, _DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float);
            float _Property_e743d6a6031845bebcd1b79a88ad2246_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_32f30c928e1b4a37ae49ec0875a29f14;
            float _CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float, _Property_e743d6a6031845bebcd1b79a88ad2246_Out_0_Float, _CutOut_32f30c928e1b4a37ae49ec0875a29f14, _CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float);
            UnityTexture2D _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_92eacbf2f91648cdb680cb07b4c84d83_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_c854dcb8c14345c08ccf253c400d0e82_Out_0_Float = _FoamTiling;
            float2 _Property_c0d69e7204734c43812eddc139c336c5_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c0d69e7204734c43812eddc139c336c5_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2);
            float2 _TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_92eacbf2f91648cdb680cb07b4c84d83_Out_1_Vector2, (_Property_c854dcb8c14345c08ccf253c400d0e82_Out_0_Float.xx), _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2, _TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2);
            float4 _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.tex, _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.samplerstate, _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2) );
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_R_4_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.r;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_G_5_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.g;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_B_6_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.b;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_A_7_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.a;
            float _Property_a30767ada2554636b433757722d925a5_Out_0_Float = _FoamDepth;
            float _Property_85a722b2d97c4696b06bd34d41768fc0_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_8253d0b28799460d91b86aaa80bda820;
            _DepthFade_8253d0b28799460d91b86aaa80bda820.ScreenPosition = IN.ScreenPosition;
            _DepthFade_8253d0b28799460d91b86aaa80bda820.NDCPosition = IN.NDCPosition;
            float _DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_a30767ada2554636b433757722d925a5_Out_0_Float, _Property_85a722b2d97c4696b06bd34d41768fc0_Out_0_Float, _DepthFade_8253d0b28799460d91b86aaa80bda820, _DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float);
            float4 _Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4, (_DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float.xxxx), _Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4);
            float _Property_e84b809010eb4099a84f1fe170e78493_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_24054a506ba44d258a9324359f9ab56c;
            float _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4).x, _Property_e84b809010eb4099a84f1fe170e78493_Out_0_Float, _CutOut_24054a506ba44d258a9324359f9ab56c, _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float);
            float _Add_3152088544f14edd9b579a71529e5eab_Out_2_Float;
            Unity_Add_float(_CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float, _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float, _Add_3152088544f14edd9b579a71529e5eab_Out_2_Float);
            float _Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float;
            Unity_Saturate_float(_Add_3152088544f14edd9b579a71529e5eab_Out_2_Float, _Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float);
            float4 _Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_6621c89d7b3041c98c7849814df9ca18_Out_0_Vector4, (_Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float.xxxx), _Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4);
            float4 _Property_92817ffb792e498491a70743808f9fb4_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_3f698ea5418d4b8a912b10d83ed0ddaf_Out_0_Float = _CausticsTiling;
            float _Property_036faa83e6af4cffb09d74a3bce4b1d4_Out_0_Float = _CausticsSpeed;
            float _Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float;
            Unity_Multiply_float_float(_Property_036faa83e6af4cffb09d74a3bce4b1d4_Out_0_Float, IN.TimeParameters.x, _Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float);
            float2 _TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3f698ea5418d4b8a912b10d83ed0ddaf_Out_0_Float.xx), (_Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float.xx), _TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2);
            float4 _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.tex, _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.samplerstate, _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2) );
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_R_4_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.r;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_G_5_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.g;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_B_6_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.b;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_A_7_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.a;
            UnityTexture2D _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_ae261fa440f7445f9680d4786d9e8d6c_Out_0_Float = _CausticsTiling;
            float _Property_d46424b6f49948c48d8aa5a54e86ab37_Out_0_Float = _CausticsSpeed;
            float _Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float;
            Unity_Multiply_float_float(_Property_d46424b6f49948c48d8aa5a54e86ab37_Out_0_Float, IN.TimeParameters.x, _Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float);
            float _Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float, -1, _Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float);
            float2 _TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_ae261fa440f7445f9680d4786d9e8d6c_Out_0_Float.xx), (_Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float.xx), _TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2);
            float4 _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.tex, _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.samplerstate, _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2) );
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_R_4_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.r;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_G_5_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.g;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_B_6_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.b;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_A_7_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.a;
            float4 _Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4, _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4, _Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4);
            float _Property_ea45466b5ff042dd9d72e0cb76d96729_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dd8e2a36eea948e9b85e89c106e39db9;
            float _CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4).x, _Property_ea45466b5ff042dd9d72e0cb76d96729_Out_0_Float, _CutOut_dd8e2a36eea948e9b85e89c106e39db9, _CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float);
            float4 _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_92817ffb792e498491a70743808f9fb4_Out_0_Vector4, (_CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float.xxxx), _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4);
            float4 _Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4;
            Unity_Add_float4(_Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4, _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4, _Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4);
            float _OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float;
            Unity_OneMinus_float(_Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float, _OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float);
            float _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float;
            Unity_OneMinus_float(_CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float, _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float);
            float _Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float;
            Unity_Add_float(_OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float, _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float, _Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float);
            float4 _Property_160f368928724737bd8d235406114282_Out_0_Vector4 = _ShoreColor;
            float _Property_1d8e92e9cd9d411ba17bf254d5c0ac2e_Out_0_Float = _Depth;
            float _Property_a2f1df831feb4ce7a481ba10d6dd5d6e_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7;
            _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7.ScreenPosition = IN.ScreenPosition;
            _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7.NDCPosition = IN.NDCPosition;
            float _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_1d8e92e9cd9d411ba17bf254d5c0ac2e_Out_0_Float, _Property_a2f1df831feb4ce7a481ba10d6dd5d6e_Out_0_Float, _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7, _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float);
            float4 _Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_160f368928724737bd8d235406114282_Out_0_Vector4, (_DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float.xxxx), _Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4);
            float _OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float, _OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float);
            float4 _Property_69288d55badb4bc4a9132d27bf2ecfe6_Out_0_Vector4 = _MainColor;
            float4 _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float.xxxx), _Property_69288d55badb4bc4a9132d27bf2ecfe6_Out_0_Vector4, _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4);
            float4 _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4;
            Unity_Add_float4(_Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4, _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4, _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4);
            float4 _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float.xxxx), _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4, _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4);
            float4 _Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4;
            Unity_Add_float4(_Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4, _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4, _Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4);
            // Second foam ring using Step (hard edge, cartoon style)
            float _SecondFoamTotalWidth = _FoamShoreWidth + _SecondFoamWidth;
            float _DepthFadeShore_SecondFoam;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_360d81065f0a4a859a99f08b7011f10a, _DepthFadeShore_SecondFoam);
            float _Step_SecondFoamOuter = step(_DepthFadeShore_SecondFoam, _SecondFoamTotalWidth);
            float _Step_SecondFoamInner = step(_DepthFadeShore_SecondFoam, _FoamShoreWidth);
            float _SecondFoamMask = saturate(_Step_SecondFoamOuter - _Step_SecondFoamInner);
            float4 _SecondFoamColorValue = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;

            // Lerp: donde hay segundo foam tapa completamente al primero, sin mezcla aditiva
            float4 _Add_WithSecondFoam = lerp(_Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4, _SecondFoamColorValue, _SecondFoamMask);

            float4 _Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4;
            Unity_Add_float4(_FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4, _Add_WithSecondFoam, _Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4);
            surface.BaseColor = (_Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Smoothness = float(0.5);
            surface.Occlusion = float(1);
            surface.Alpha = float(1);
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif

            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif





            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);

            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif

            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;

            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
        }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif

        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Depth;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
        float _SecondFoamWidth;
        float4 _SecondFoamColor;
        float4 _FoamTexture_TexelSize;
        float _FoamDepth;
        float _FoamFallOff;
        float _FoamTiling;
        float2 _FoamSpeed;
        float _FoamAmount;
        float _FoamCutOut;
        float4 _CausticTexture_TexelSize;
        float _CausticCutOut;
        float4 _CausticColor;
        float _CausticsTiling;
        float _CausticsSpeed;
        float _WaveIntensity;
        float _WaveSpeed;
        float _FlowSpeed;
        float _FlowStrength;
        float4 _FlowMap_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END


        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FoamTexture);
        SAMPLER(sampler_FoamTexture);
        TEXTURE2D(_CausticTexture);
        SAMPLER(sampler_CausticTexture);
        TEXTURE2D(_FlowMap);
        SAMPLER(sampler_FlowMap);

        // Graph Includes
        // GraphIncludes: <None>

        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

        // Graph Functions

        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float = _WaveIntensity;
            float3 _Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3 = float3(float(0), _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float, float(0));
            float _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float = _WaveSpeed;
            float _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float, _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float);
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_A_4_Float = 0;
            float _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float;
            Unity_Add_float(_Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float, _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float);
            float _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float;
            Unity_Add_float(_Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float, _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float);
            float _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float;
            Unity_Sine_float(_Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float, _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float);
            float3 _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3, (_Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float.xxx), _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3);
            float3 _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3, _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3);
            description.Position = _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = float(1);
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif

            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif








            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif


        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
        }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif

        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }

        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask RG

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Depth;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
        float _SecondFoamWidth;
        float4 _SecondFoamColor;
        float4 _FoamTexture_TexelSize;
        float _FoamDepth;
        float _FoamFallOff;
        float _FoamTiling;
        float2 _FoamSpeed;
        float _FoamAmount;
        float _FoamCutOut;
        float4 _CausticTexture_TexelSize;
        float _CausticCutOut;
        float4 _CausticColor;
        float _CausticsTiling;
        float _CausticsSpeed;
        float _WaveIntensity;
        float _WaveSpeed;
        float _FlowSpeed;
        float _FlowStrength;
        float4 _FlowMap_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END


        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FoamTexture);
        SAMPLER(sampler_FoamTexture);
        TEXTURE2D(_CausticTexture);
        SAMPLER(sampler_CausticTexture);
        TEXTURE2D(_FlowMap);
        SAMPLER(sampler_FlowMap);

        // Graph Includes
        // GraphIncludes: <None>

        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

        // Graph Functions

        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float = _WaveIntensity;
            float3 _Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3 = float3(float(0), _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float, float(0));
            float _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float = _WaveSpeed;
            float _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float, _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float);
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_A_4_Float = 0;
            float _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float;
            Unity_Add_float(_Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float, _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float);
            float _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float;
            Unity_Add_float(_Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float, _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float);
            float _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float;
            Unity_Sine_float(_Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float, _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float);
            float3 _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3, (_Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float.xxx), _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3);
            float3 _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3, _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3);
            description.Position = _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            return description;
        }

        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = float(1);
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif

            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif








            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif


        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
        }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"

        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif

        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Depth;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
        float _SecondFoamWidth;
        float4 _SecondFoamColor;
        float4 _FoamTexture_TexelSize;
        float _FoamDepth;
        float _FoamFallOff;
        float _FoamTiling;
        float2 _FoamSpeed;
        float _FoamAmount;
        float _FoamCutOut;
        float4 _CausticTexture_TexelSize;
        float _CausticCutOut;
        float4 _CausticColor;
        float _CausticsTiling;
        float _CausticsSpeed;
        float _WaveIntensity;
        float _WaveSpeed;
        float _FlowSpeed;
        float _FlowStrength;
        float4 _FlowMap_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END


        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FoamTexture);
        SAMPLER(sampler_FoamTexture);
        TEXTURE2D(_CausticTexture);
        SAMPLER(sampler_CausticTexture);
        TEXTURE2D(_FlowMap);
        SAMPLER(sampler_FlowMap);

        // Graph Includes
        // GraphIncludes: <None>

        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

        // Graph Functions

        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float = _WaveIntensity;
            float3 _Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3 = float3(float(0), _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float, float(0));
            float _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float = _WaveSpeed;
            float _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float, _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float);
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_A_4_Float = 0;
            float _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float;
            Unity_Add_float(_Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float, _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float);
            float _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float;
            Unity_Add_float(_Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float, _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float);
            float _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float;
            Unity_Sine_float(_Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float, _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float);
            float3 _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3, (_Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float.xxx), _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3);
            float3 _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3, _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3);
            description.Position = _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = float(1);
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif

            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif





            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif


        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
        }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif

        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

        // Render State
        Cull Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_INSTANCEID
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define REQUIRE_DEPTH_TEXTURE


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float3 positionWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Depth;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
        float _SecondFoamWidth;
        float4 _SecondFoamColor;
        float4 _FoamTexture_TexelSize;
        float _FoamDepth;
        float _FoamFallOff;
        float _FoamTiling;
        float2 _FoamSpeed;
        float _FoamAmount;
        float _FoamCutOut;
        float4 _CausticTexture_TexelSize;
        float _CausticCutOut;
        float4 _CausticColor;
        float _CausticsTiling;
        float _CausticsSpeed;
        float _WaveIntensity;
        float _WaveSpeed;
        float _FlowSpeed;
        float _FlowStrength;
        float4 _FlowMap_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END


        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FoamTexture);
        SAMPLER(sampler_FoamTexture);
        TEXTURE2D(_CausticTexture);
        SAMPLER(sampler_CausticTexture);
        TEXTURE2D(_FlowMap);
        SAMPLER(sampler_FlowMap);

        // Graph Includes
        // GraphIncludes: <None>

        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

        // Graph Functions

        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }

        // unity-custom-func-begin
        void FlowUV_float(float FlowSpeed, float Time, float2 UV, float2 FlowVector, out float2 UV1, out float2 UV2, out float Blend){
        float phase0 = Time * FlowSpeed - floor(Time * FlowSpeed);
        float phase1 = (Time * FlowSpeed + 0.5) - floor(Time * FlowSpeed + 0.5);

        UV1 = UV - FlowVector * phase0;
        UV2 = UV - FlowVector * phase1;

        Blend = abs((phase0 - 0.5) * 2.0);
        }
        // unity-custom-func-end

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        struct Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float
        {
        half4 uv0;
        float3 TimeParameters;
        };

        void SG_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float(float _FlowSpeed, float _FlowStrength, UnityTexture2D _FlowMap, UnityTexture2D _WaterTexture, Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float IN, out float4 UV2_2)
        {
        UnityTexture2D _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D = _WaterTexture;
        float _Property_d98c376d1ee546138072a488daec8b4c_Out_0_Float = _FlowSpeed;
        float4 _UV_bf331151e19d4743ac71b3a059904a4a_Out_0_Vector4 = IN.uv0;
        UnityTexture2D _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D = _FlowMap;
        float4 _UV_c10f5674a32049da84c46a321ffdfb6d_Out_0_Vector4 = IN.uv0;
        float4 _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.tex, _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.samplerstate, _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.GetTransformedUV((_UV_c10f5674a32049da84c46a321ffdfb6d_Out_0_Vector4.xy)) );
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_R_4_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.r;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_G_5_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.g;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_B_6_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.b;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_A_7_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.a;
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_R_1_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[0];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_G_2_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[1];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_B_3_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[2];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_A_4_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[3];
        float _Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float;
        Unity_Remap_float(_Split_6adf8f8dbcff4b98af7d114ecc255d36_G_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float);
        float _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float;
        Unity_Remap_float(_Split_6adf8f8dbcff4b98af7d114ecc255d36_R_1_Float, float2 (0, 1), float2 (-1, 1), _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float);
        float2 _Vector2_f223a963e73e447b88759a8aeaf7da92_Out_0_Vector2 = float2(_Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float, _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float);
        float _Property_8027a7e0aa194e549b8cd3e1219acce4_Out_0_Float = _FlowStrength;
        float2 _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_f223a963e73e447b88759a8aeaf7da92_Out_0_Vector2, (_Property_8027a7e0aa194e549b8cd3e1219acce4_Out_0_Float.xx), _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2);
        float2 _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2;
        float2 _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2;
        float _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float;
        FlowUV_float(_Property_d98c376d1ee546138072a488daec8b4c_Out_0_Float, IN.TimeParameters.x, (_UV_bf331151e19d4743ac71b3a059904a4a_Out_0_Vector4.xy), _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float);
        float4 _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.tex, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.samplerstate, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.GetTransformedUV(_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2) );
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_R_4_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.r;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_G_5_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.g;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_B_6_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.b;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_A_7_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.a;
        float4 _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.tex, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.samplerstate, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.GetTransformedUV(_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2) );
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_R_4_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.r;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_G_5_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.g;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_B_6_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.b;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_A_7_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.a;
        float4 _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4;
        Unity_Lerp_float4(_SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4, _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4, (_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float.xxxx), _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4);
        UV2_2 = _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        struct Bindings_DepthFade_fd37366848b771042941ee5121343adf_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };

        void SG_DepthFade_fd37366848b771042941ee5121343adf_float(float _Depth, float _DepthFallOff, Bindings_DepthFade_fd37366848b771042941ee5121343adf_float IN, out float OutVector1_1)
        {
        float _SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float);
        float4 _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_4283d983846047c3931269c4f290d4f9_R_1_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[0];
        float _Split_4283d983846047c3931269c4f290d4f9_G_2_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[1];
        float _Split_4283d983846047c3931269c4f290d4f9_B_3_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[2];
        float _Split_4283d983846047c3931269c4f290d4f9_A_4_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[3];
        float _Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float, _Split_4283d983846047c3931269c4f290d4f9_A_4_Float, _Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float);
        float _Property_2376aa4d3f03452fb19c1b6fe12cdd9d_Out_0_Float = _Depth;
        float _Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float;
        Unity_Divide_float(_Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float, _Property_2376aa4d3f03452fb19c1b6fe12cdd9d_Out_0_Float, _Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float);
        float _OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float;
        Unity_OneMinus_float(_Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float, _OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float);
        float _Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float;
        Unity_Saturate_float(_OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float, _Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float);
        float _Property_9c8e44da412b47a8a20d93b3cf08bd70_Out_0_Float = _DepthFallOff;
        float _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float;
        Unity_Maximum_float(_Property_9c8e44da412b47a8a20d93b3cf08bd70_Out_0_Float, float(0.005), _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float);
        float _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float;
        Unity_Power_float(_Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float, _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float, _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float);
        OutVector1_1 = _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float;
        }

        void Unity_Ceiling_float(float In, out float Out)
        {
            Out = ceil(In);
        }

        struct Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float
        {
        };

        void SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(float _Input, float _Alpha, Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float IN, out float Output_0)
        {
        float _Property_ca30cb36add94aabaa9d9dabfda56c02_Out_0_Float = _Input;
        float _Property_d3832a99da2f48919b2e31df6ee1452a_Out_0_Float = _Alpha;
        float _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float;
        Unity_Saturate_float(_Property_d3832a99da2f48919b2e31df6ee1452a_Out_0_Float, _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float);
        float _Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float;
        Unity_Subtract_float(_Property_ca30cb36add94aabaa9d9dabfda56c02_Out_0_Float, _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float, _Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float);
        float _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float;
        Unity_Ceiling_float(_Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float, _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float);
        Output_0 = _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float = _WaveIntensity;
            float3 _Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3 = float3(float(0), _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float, float(0));
            float _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float = _WaveSpeed;
            float _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float, _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float);
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_A_4_Float = 0;
            float _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float;
            Unity_Add_float(_Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float, _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float);
            float _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float;
            Unity_Add_float(_Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float, _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float);
            float _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float;
            Unity_Sine_float(_Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float, _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float);
            float3 _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3, (_Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float.xxx), _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3);
            float3 _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3, _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3);
            description.Position = _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_622f4b00a9ea415788676ffe06990d8e_Out_0_Float = _FlowSpeed;
            float _Property_d81dfb1a7514478f9e84e798877f387f_Out_0_Float = _FlowStrength;
            UnityTexture2D _Property_6f00f50a994a4340bbecb9a1603af3bd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FlowMap);
            UnityTexture2D _Property_3edce890842648a893430eea92089e01_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd;
            _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd.uv0 = IN.uv0;
            _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd.TimeParameters = IN.TimeParameters;
            float4 _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4;
            SG_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float(_Property_622f4b00a9ea415788676ffe06990d8e_Out_0_Float, _Property_d81dfb1a7514478f9e84e798877f387f_Out_0_Float, _Property_6f00f50a994a4340bbecb9a1603af3bd_Out_0_Texture2D, _Property_3edce890842648a893430eea92089e01_Out_0_Texture2D, _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd, _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4);
            float4 _Property_6621c89d7b3041c98c7849814df9ca18_Out_0_Vector4 = _FoamColor;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_360d81065f0a4a859a99f08b7011f10a;
            _DepthFade_360d81065f0a4a859a99f08b7011f10a.ScreenPosition = IN.ScreenPosition;
            _DepthFade_360d81065f0a4a859a99f08b7011f10a.NDCPosition = IN.NDCPosition;
            float _DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_360d81065f0a4a859a99f08b7011f10a, _DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float);
            float _Property_e743d6a6031845bebcd1b79a88ad2246_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_32f30c928e1b4a37ae49ec0875a29f14;
            float _CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float, _Property_e743d6a6031845bebcd1b79a88ad2246_Out_0_Float, _CutOut_32f30c928e1b4a37ae49ec0875a29f14, _CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float);
            UnityTexture2D _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_92eacbf2f91648cdb680cb07b4c84d83_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_c854dcb8c14345c08ccf253c400d0e82_Out_0_Float = _FoamTiling;
            float2 _Property_c0d69e7204734c43812eddc139c336c5_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c0d69e7204734c43812eddc139c336c5_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2);
            float2 _TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_92eacbf2f91648cdb680cb07b4c84d83_Out_1_Vector2, (_Property_c854dcb8c14345c08ccf253c400d0e82_Out_0_Float.xx), _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2, _TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2);
            float4 _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.tex, _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.samplerstate, _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2) );
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_R_4_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.r;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_G_5_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.g;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_B_6_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.b;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_A_7_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.a;
            float _Property_a30767ada2554636b433757722d925a5_Out_0_Float = _FoamDepth;
            float _Property_85a722b2d97c4696b06bd34d41768fc0_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_8253d0b28799460d91b86aaa80bda820;
            _DepthFade_8253d0b28799460d91b86aaa80bda820.ScreenPosition = IN.ScreenPosition;
            _DepthFade_8253d0b28799460d91b86aaa80bda820.NDCPosition = IN.NDCPosition;
            float _DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_a30767ada2554636b433757722d925a5_Out_0_Float, _Property_85a722b2d97c4696b06bd34d41768fc0_Out_0_Float, _DepthFade_8253d0b28799460d91b86aaa80bda820, _DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float);
            float4 _Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4, (_DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float.xxxx), _Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4);
            float _Property_e84b809010eb4099a84f1fe170e78493_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_24054a506ba44d258a9324359f9ab56c;
            float _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4).x, _Property_e84b809010eb4099a84f1fe170e78493_Out_0_Float, _CutOut_24054a506ba44d258a9324359f9ab56c, _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float);
            float _Add_3152088544f14edd9b579a71529e5eab_Out_2_Float;
            Unity_Add_float(_CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float, _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float, _Add_3152088544f14edd9b579a71529e5eab_Out_2_Float);
            float _Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float;
            Unity_Saturate_float(_Add_3152088544f14edd9b579a71529e5eab_Out_2_Float, _Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float);
            float4 _Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_6621c89d7b3041c98c7849814df9ca18_Out_0_Vector4, (_Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float.xxxx), _Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4);
            float4 _Property_92817ffb792e498491a70743808f9fb4_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_3f698ea5418d4b8a912b10d83ed0ddaf_Out_0_Float = _CausticsTiling;
            float _Property_036faa83e6af4cffb09d74a3bce4b1d4_Out_0_Float = _CausticsSpeed;
            float _Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float;
            Unity_Multiply_float_float(_Property_036faa83e6af4cffb09d74a3bce4b1d4_Out_0_Float, IN.TimeParameters.x, _Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float);
            float2 _TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3f698ea5418d4b8a912b10d83ed0ddaf_Out_0_Float.xx), (_Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float.xx), _TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2);
            float4 _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.tex, _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.samplerstate, _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2) );
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_R_4_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.r;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_G_5_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.g;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_B_6_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.b;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_A_7_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.a;
            UnityTexture2D _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_ae261fa440f7445f9680d4786d9e8d6c_Out_0_Float = _CausticsTiling;
            float _Property_d46424b6f49948c48d8aa5a54e86ab37_Out_0_Float = _CausticsSpeed;
            float _Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float;
            Unity_Multiply_float_float(_Property_d46424b6f49948c48d8aa5a54e86ab37_Out_0_Float, IN.TimeParameters.x, _Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float);
            float _Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float, -1, _Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float);
            float2 _TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_ae261fa440f7445f9680d4786d9e8d6c_Out_0_Float.xx), (_Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float.xx), _TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2);
            float4 _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.tex, _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.samplerstate, _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2) );
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_R_4_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.r;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_G_5_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.g;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_B_6_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.b;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_A_7_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.a;
            float4 _Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4, _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4, _Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4);
            float _Property_ea45466b5ff042dd9d72e0cb76d96729_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dd8e2a36eea948e9b85e89c106e39db9;
            float _CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4).x, _Property_ea45466b5ff042dd9d72e0cb76d96729_Out_0_Float, _CutOut_dd8e2a36eea948e9b85e89c106e39db9, _CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float);
            float4 _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_92817ffb792e498491a70743808f9fb4_Out_0_Vector4, (_CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float.xxxx), _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4);
            float4 _Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4;
            Unity_Add_float4(_Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4, _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4, _Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4);
            float _OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float;
            Unity_OneMinus_float(_Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float, _OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float);
            float _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float;
            Unity_OneMinus_float(_CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float, _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float);
            float _Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float;
            Unity_Add_float(_OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float, _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float, _Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float);
            float4 _Property_160f368928724737bd8d235406114282_Out_0_Vector4 = _ShoreColor;
            float _Property_1d8e92e9cd9d411ba17bf254d5c0ac2e_Out_0_Float = _Depth;
            float _Property_a2f1df831feb4ce7a481ba10d6dd5d6e_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7;
            _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7.ScreenPosition = IN.ScreenPosition;
            _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7.NDCPosition = IN.NDCPosition;
            float _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_1d8e92e9cd9d411ba17bf254d5c0ac2e_Out_0_Float, _Property_a2f1df831feb4ce7a481ba10d6dd5d6e_Out_0_Float, _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7, _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float);
            float4 _Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_160f368928724737bd8d235406114282_Out_0_Vector4, (_DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float.xxxx), _Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4);
            float _OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float, _OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float);
            float4 _Property_69288d55badb4bc4a9132d27bf2ecfe6_Out_0_Vector4 = _MainColor;
            float4 _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float.xxxx), _Property_69288d55badb4bc4a9132d27bf2ecfe6_Out_0_Vector4, _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4);
            float4 _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4;
            Unity_Add_float4(_Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4, _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4, _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4);
            float4 _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float.xxxx), _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4, _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4);
            float4 _Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4;
            Unity_Add_float4(_Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4, _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4, _Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4);
            // Second foam ring using Step (hard edge, cartoon style)
            float _SecondFoamTotalWidth = _FoamShoreWidth + _SecondFoamWidth;
            float _DepthFadeShore_SecondFoam;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_360d81065f0a4a859a99f08b7011f10a, _DepthFadeShore_SecondFoam);
            float _Step_SecondFoamOuter = step(_DepthFadeShore_SecondFoam, _SecondFoamTotalWidth);
            float _Step_SecondFoamInner = step(_DepthFadeShore_SecondFoam, _FoamShoreWidth);
            float _SecondFoamMask = saturate(_Step_SecondFoamOuter - _Step_SecondFoamInner);
            float4 _SecondFoamColorValue = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;

            // Lerp: donde hay segundo foam tapa completamente al primero, sin mezcla aditiva
            float4 _Add_WithSecondFoam = lerp(_Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4, _SecondFoamColorValue, _SecondFoamMask);

            float4 _Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4;
            Unity_Add_float4(_FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4, _Add_WithSecondFoam, _Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4);
            surface.BaseColor = (_Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = float(1);
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif

            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif







            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);

            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif

            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;

            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
        }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif

        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }

        // Render State
        Cull Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Depth;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
        float _SecondFoamWidth;
        float4 _SecondFoamColor;
        float4 _FoamTexture_TexelSize;
        float _FoamDepth;
        float _FoamFallOff;
        float _FoamTiling;
        float2 _FoamSpeed;
        float _FoamAmount;
        float _FoamCutOut;
        float4 _CausticTexture_TexelSize;
        float _CausticCutOut;
        float4 _CausticColor;
        float _CausticsTiling;
        float _CausticsSpeed;
        float _WaveIntensity;
        float _WaveSpeed;
        float _FlowSpeed;
        float _FlowStrength;
        float4 _FlowMap_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END


        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FoamTexture);
        SAMPLER(sampler_FoamTexture);
        TEXTURE2D(_CausticTexture);
        SAMPLER(sampler_CausticTexture);
        TEXTURE2D(_FlowMap);
        SAMPLER(sampler_FlowMap);

        // Graph Includes
        // GraphIncludes: <None>

        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

        // Graph Functions

        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float = _WaveIntensity;
            float3 _Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3 = float3(float(0), _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float, float(0));
            float _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float = _WaveSpeed;
            float _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float, _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float);
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_A_4_Float = 0;
            float _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float;
            Unity_Add_float(_Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float, _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float);
            float _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float;
            Unity_Add_float(_Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float, _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float);
            float _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float;
            Unity_Sine_float(_Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float, _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float);
            float3 _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3, (_Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float.xxx), _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3);
            float3 _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3, _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3);
            description.Position = _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = float(1);
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif

            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif








            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif


        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
        }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif

        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }

        // Render State
        Cull Back

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Depth;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
        float _SecondFoamWidth;
        float4 _SecondFoamColor;
        float4 _FoamTexture_TexelSize;
        float _FoamDepth;
        float _FoamFallOff;
        float _FoamTiling;
        float2 _FoamSpeed;
        float _FoamAmount;
        float _FoamCutOut;
        float4 _CausticTexture_TexelSize;
        float _CausticCutOut;
        float4 _CausticColor;
        float _CausticsTiling;
        float _CausticsSpeed;
        float _WaveIntensity;
        float _WaveSpeed;
        float _FlowSpeed;
        float _FlowStrength;
        float4 _FlowMap_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END


        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FoamTexture);
        SAMPLER(sampler_FoamTexture);
        TEXTURE2D(_CausticTexture);
        SAMPLER(sampler_CausticTexture);
        TEXTURE2D(_FlowMap);
        SAMPLER(sampler_FlowMap);

        // Graph Includes
        // GraphIncludes: <None>

        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

        // Graph Functions

        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }

        // unity-custom-func-begin
        void FlowUV_float(float FlowSpeed, float Time, float2 UV, float2 FlowVector, out float2 UV1, out float2 UV2, out float Blend){
        float phase0 = Time * FlowSpeed - floor(Time * FlowSpeed);
        float phase1 = (Time * FlowSpeed + 0.5) - floor(Time * FlowSpeed + 0.5);

        UV1 = UV - FlowVector * phase0;
        UV2 = UV - FlowVector * phase1;

        Blend = abs((phase0 - 0.5) * 2.0);
        }
        // unity-custom-func-end

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        struct Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float
        {
        half4 uv0;
        float3 TimeParameters;
        };

        void SG_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float(float _FlowSpeed, float _FlowStrength, UnityTexture2D _FlowMap, UnityTexture2D _WaterTexture, Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float IN, out float4 UV2_2)
        {
        UnityTexture2D _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D = _WaterTexture;
        float _Property_d98c376d1ee546138072a488daec8b4c_Out_0_Float = _FlowSpeed;
        float4 _UV_bf331151e19d4743ac71b3a059904a4a_Out_0_Vector4 = IN.uv0;
        UnityTexture2D _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D = _FlowMap;
        float4 _UV_c10f5674a32049da84c46a321ffdfb6d_Out_0_Vector4 = IN.uv0;
        float4 _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.tex, _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.samplerstate, _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.GetTransformedUV((_UV_c10f5674a32049da84c46a321ffdfb6d_Out_0_Vector4.xy)) );
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_R_4_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.r;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_G_5_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.g;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_B_6_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.b;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_A_7_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.a;
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_R_1_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[0];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_G_2_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[1];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_B_3_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[2];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_A_4_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[3];
        float _Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float;
        Unity_Remap_float(_Split_6adf8f8dbcff4b98af7d114ecc255d36_G_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float);
        float _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float;
        Unity_Remap_float(_Split_6adf8f8dbcff4b98af7d114ecc255d36_R_1_Float, float2 (0, 1), float2 (-1, 1), _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float);
        float2 _Vector2_f223a963e73e447b88759a8aeaf7da92_Out_0_Vector2 = float2(_Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float, _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float);
        float _Property_8027a7e0aa194e549b8cd3e1219acce4_Out_0_Float = _FlowStrength;
        float2 _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_f223a963e73e447b88759a8aeaf7da92_Out_0_Vector2, (_Property_8027a7e0aa194e549b8cd3e1219acce4_Out_0_Float.xx), _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2);
        float2 _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2;
        float2 _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2;
        float _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float;
        FlowUV_float(_Property_d98c376d1ee546138072a488daec8b4c_Out_0_Float, IN.TimeParameters.x, (_UV_bf331151e19d4743ac71b3a059904a4a_Out_0_Vector4.xy), _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float);
        float4 _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.tex, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.samplerstate, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.GetTransformedUV(_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2) );
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_R_4_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.r;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_G_5_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.g;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_B_6_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.b;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_A_7_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.a;
        float4 _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.tex, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.samplerstate, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.GetTransformedUV(_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2) );
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_R_4_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.r;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_G_5_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.g;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_B_6_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.b;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_A_7_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.a;
        float4 _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4;
        Unity_Lerp_float4(_SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4, _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4, (_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float.xxxx), _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4);
        UV2_2 = _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        struct Bindings_DepthFade_fd37366848b771042941ee5121343adf_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };

        void SG_DepthFade_fd37366848b771042941ee5121343adf_float(float _Depth, float _DepthFallOff, Bindings_DepthFade_fd37366848b771042941ee5121343adf_float IN, out float OutVector1_1)
        {
        float _SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float);
        float4 _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_4283d983846047c3931269c4f290d4f9_R_1_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[0];
        float _Split_4283d983846047c3931269c4f290d4f9_G_2_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[1];
        float _Split_4283d983846047c3931269c4f290d4f9_B_3_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[2];
        float _Split_4283d983846047c3931269c4f290d4f9_A_4_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[3];
        float _Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float, _Split_4283d983846047c3931269c4f290d4f9_A_4_Float, _Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float);
        float _Property_2376aa4d3f03452fb19c1b6fe12cdd9d_Out_0_Float = _Depth;
        float _Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float;
        Unity_Divide_float(_Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float, _Property_2376aa4d3f03452fb19c1b6fe12cdd9d_Out_0_Float, _Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float);
        float _OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float;
        Unity_OneMinus_float(_Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float, _OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float);
        float _Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float;
        Unity_Saturate_float(_OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float, _Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float);
        float _Property_9c8e44da412b47a8a20d93b3cf08bd70_Out_0_Float = _DepthFallOff;
        float _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float;
        Unity_Maximum_float(_Property_9c8e44da412b47a8a20d93b3cf08bd70_Out_0_Float, float(0.005), _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float);
        float _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float;
        Unity_Power_float(_Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float, _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float, _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float);
        OutVector1_1 = _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float;
        }

        void Unity_Ceiling_float(float In, out float Out)
        {
            Out = ceil(In);
        }

        struct Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float
        {
        };

        void SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(float _Input, float _Alpha, Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float IN, out float Output_0)
        {
        float _Property_ca30cb36add94aabaa9d9dabfda56c02_Out_0_Float = _Input;
        float _Property_d3832a99da2f48919b2e31df6ee1452a_Out_0_Float = _Alpha;
        float _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float;
        Unity_Saturate_float(_Property_d3832a99da2f48919b2e31df6ee1452a_Out_0_Float, _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float);
        float _Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float;
        Unity_Subtract_float(_Property_ca30cb36add94aabaa9d9dabfda56c02_Out_0_Float, _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float, _Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float);
        float _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float;
        Unity_Ceiling_float(_Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float, _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float);
        Output_0 = _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float = _WaveIntensity;
            float3 _Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3 = float3(float(0), _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float, float(0));
            float _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float = _WaveSpeed;
            float _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float, _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float);
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_A_4_Float = 0;
            float _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float;
            Unity_Add_float(_Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float, _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float);
            float _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float;
            Unity_Add_float(_Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float, _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float);
            float _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float;
            Unity_Sine_float(_Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float, _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float);
            float3 _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3, (_Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float.xxx), _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3);
            float3 _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3, _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3);
            description.Position = _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_622f4b00a9ea415788676ffe06990d8e_Out_0_Float = _FlowSpeed;
            float _Property_d81dfb1a7514478f9e84e798877f387f_Out_0_Float = _FlowStrength;
            UnityTexture2D _Property_6f00f50a994a4340bbecb9a1603af3bd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FlowMap);
            UnityTexture2D _Property_3edce890842648a893430eea92089e01_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd;
            _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd.uv0 = IN.uv0;
            _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd.TimeParameters = IN.TimeParameters;
            float4 _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4;
            SG_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float(_Property_622f4b00a9ea415788676ffe06990d8e_Out_0_Float, _Property_d81dfb1a7514478f9e84e798877f387f_Out_0_Float, _Property_6f00f50a994a4340bbecb9a1603af3bd_Out_0_Texture2D, _Property_3edce890842648a893430eea92089e01_Out_0_Texture2D, _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd, _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4);
            float4 _Property_6621c89d7b3041c98c7849814df9ca18_Out_0_Vector4 = _FoamColor;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_360d81065f0a4a859a99f08b7011f10a;
            _DepthFade_360d81065f0a4a859a99f08b7011f10a.ScreenPosition = IN.ScreenPosition;
            _DepthFade_360d81065f0a4a859a99f08b7011f10a.NDCPosition = IN.NDCPosition;
            float _DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_360d81065f0a4a859a99f08b7011f10a, _DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float);
            float _Property_e743d6a6031845bebcd1b79a88ad2246_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_32f30c928e1b4a37ae49ec0875a29f14;
            float _CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float, _Property_e743d6a6031845bebcd1b79a88ad2246_Out_0_Float, _CutOut_32f30c928e1b4a37ae49ec0875a29f14, _CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float);
            UnityTexture2D _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_92eacbf2f91648cdb680cb07b4c84d83_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_c854dcb8c14345c08ccf253c400d0e82_Out_0_Float = _FoamTiling;
            float2 _Property_c0d69e7204734c43812eddc139c336c5_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c0d69e7204734c43812eddc139c336c5_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2);
            float2 _TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_92eacbf2f91648cdb680cb07b4c84d83_Out_1_Vector2, (_Property_c854dcb8c14345c08ccf253c400d0e82_Out_0_Float.xx), _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2, _TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2);
            float4 _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.tex, _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.samplerstate, _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2) );
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_R_4_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.r;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_G_5_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.g;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_B_6_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.b;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_A_7_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.a;
            float _Property_a30767ada2554636b433757722d925a5_Out_0_Float = _FoamDepth;
            float _Property_85a722b2d97c4696b06bd34d41768fc0_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_8253d0b28799460d91b86aaa80bda820;
            _DepthFade_8253d0b28799460d91b86aaa80bda820.ScreenPosition = IN.ScreenPosition;
            _DepthFade_8253d0b28799460d91b86aaa80bda820.NDCPosition = IN.NDCPosition;
            float _DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_a30767ada2554636b433757722d925a5_Out_0_Float, _Property_85a722b2d97c4696b06bd34d41768fc0_Out_0_Float, _DepthFade_8253d0b28799460d91b86aaa80bda820, _DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float);
            float4 _Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4, (_DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float.xxxx), _Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4);
            float _Property_e84b809010eb4099a84f1fe170e78493_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_24054a506ba44d258a9324359f9ab56c;
            float _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4).x, _Property_e84b809010eb4099a84f1fe170e78493_Out_0_Float, _CutOut_24054a506ba44d258a9324359f9ab56c, _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float);
            float _Add_3152088544f14edd9b579a71529e5eab_Out_2_Float;
            Unity_Add_float(_CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float, _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float, _Add_3152088544f14edd9b579a71529e5eab_Out_2_Float);
            float _Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float;
            Unity_Saturate_float(_Add_3152088544f14edd9b579a71529e5eab_Out_2_Float, _Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float);
            float4 _Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_6621c89d7b3041c98c7849814df9ca18_Out_0_Vector4, (_Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float.xxxx), _Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4);
            float4 _Property_92817ffb792e498491a70743808f9fb4_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_3f698ea5418d4b8a912b10d83ed0ddaf_Out_0_Float = _CausticsTiling;
            float _Property_036faa83e6af4cffb09d74a3bce4b1d4_Out_0_Float = _CausticsSpeed;
            float _Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float;
            Unity_Multiply_float_float(_Property_036faa83e6af4cffb09d74a3bce4b1d4_Out_0_Float, IN.TimeParameters.x, _Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float);
            float2 _TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3f698ea5418d4b8a912b10d83ed0ddaf_Out_0_Float.xx), (_Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float.xx), _TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2);
            float4 _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.tex, _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.samplerstate, _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2) );
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_R_4_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.r;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_G_5_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.g;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_B_6_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.b;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_A_7_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.a;
            UnityTexture2D _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_ae261fa440f7445f9680d4786d9e8d6c_Out_0_Float = _CausticsTiling;
            float _Property_d46424b6f49948c48d8aa5a54e86ab37_Out_0_Float = _CausticsSpeed;
            float _Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float;
            Unity_Multiply_float_float(_Property_d46424b6f49948c48d8aa5a54e86ab37_Out_0_Float, IN.TimeParameters.x, _Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float);
            float _Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float, -1, _Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float);
            float2 _TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_ae261fa440f7445f9680d4786d9e8d6c_Out_0_Float.xx), (_Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float.xx), _TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2);
            float4 _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.tex, _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.samplerstate, _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2) );
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_R_4_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.r;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_G_5_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.g;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_B_6_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.b;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_A_7_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.a;
            float4 _Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4, _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4, _Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4);
            float _Property_ea45466b5ff042dd9d72e0cb76d96729_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dd8e2a36eea948e9b85e89c106e39db9;
            float _CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4).x, _Property_ea45466b5ff042dd9d72e0cb76d96729_Out_0_Float, _CutOut_dd8e2a36eea948e9b85e89c106e39db9, _CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float);
            float4 _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_92817ffb792e498491a70743808f9fb4_Out_0_Vector4, (_CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float.xxxx), _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4);
            float4 _Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4;
            Unity_Add_float4(_Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4, _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4, _Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4);
            float _OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float;
            Unity_OneMinus_float(_Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float, _OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float);
            float _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float;
            Unity_OneMinus_float(_CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float, _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float);
            float _Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float;
            Unity_Add_float(_OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float, _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float, _Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float);
            float4 _Property_160f368928724737bd8d235406114282_Out_0_Vector4 = _ShoreColor;
            float _Property_1d8e92e9cd9d411ba17bf254d5c0ac2e_Out_0_Float = _Depth;
            float _Property_a2f1df831feb4ce7a481ba10d6dd5d6e_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7;
            _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7.ScreenPosition = IN.ScreenPosition;
            _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7.NDCPosition = IN.NDCPosition;
            float _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_1d8e92e9cd9d411ba17bf254d5c0ac2e_Out_0_Float, _Property_a2f1df831feb4ce7a481ba10d6dd5d6e_Out_0_Float, _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7, _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float);
            float4 _Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_160f368928724737bd8d235406114282_Out_0_Vector4, (_DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float.xxxx), _Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4);
            float _OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float, _OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float);
            float4 _Property_69288d55badb4bc4a9132d27bf2ecfe6_Out_0_Vector4 = _MainColor;
            float4 _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float.xxxx), _Property_69288d55badb4bc4a9132d27bf2ecfe6_Out_0_Vector4, _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4);
            float4 _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4;
            Unity_Add_float4(_Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4, _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4, _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4);
            float4 _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float.xxxx), _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4, _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4);
            float4 _Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4;
            Unity_Add_float4(_Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4, _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4, _Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4);
            // Second foam ring using Step (hard edge, cartoon style)
            float _SecondFoamTotalWidth = _FoamShoreWidth + _SecondFoamWidth;
            float _DepthFadeShore_SecondFoam;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_360d81065f0a4a859a99f08b7011f10a, _DepthFadeShore_SecondFoam);
            float _Step_SecondFoamOuter = step(_DepthFadeShore_SecondFoam, _SecondFoamTotalWidth);
            float _Step_SecondFoamInner = step(_DepthFadeShore_SecondFoam, _FoamShoreWidth);
            float _SecondFoamMask = saturate(_Step_SecondFoamOuter - _Step_SecondFoamInner);
            float4 _SecondFoamColorValue = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;

            // Lerp: donde hay segundo foam tapa completamente al primero, sin mezcla aditiva
            float4 _Add_WithSecondFoam = lerp(_Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4, _SecondFoamColorValue, _SecondFoamMask);

            float4 _Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4;
            Unity_Add_float4(_FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4, _Add_WithSecondFoam, _Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4);
            surface.BaseColor = (_Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4.xyz);
            surface.Alpha = float(1);
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif

            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif







            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);

            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif

            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;

            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
        }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif

        ENDHLSL
        }
        Pass
        {
            Name "Universal 2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }

        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Depth;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
        float _SecondFoamWidth;
        float4 _SecondFoamColor;
        float4 _FoamTexture_TexelSize;
        float _FoamDepth;
        float _FoamFallOff;
        float _FoamTiling;
        float2 _FoamSpeed;
        float _FoamAmount;
        float _FoamCutOut;
        float4 _CausticTexture_TexelSize;
        float _CausticCutOut;
        float4 _CausticColor;
        float _CausticsTiling;
        float _CausticsSpeed;
        float _WaveIntensity;
        float _WaveSpeed;
        float _FlowSpeed;
        float _FlowStrength;
        float4 _FlowMap_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END


        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FoamTexture);
        SAMPLER(sampler_FoamTexture);
        TEXTURE2D(_CausticTexture);
        SAMPLER(sampler_CausticTexture);
        TEXTURE2D(_FlowMap);
        SAMPLER(sampler_FlowMap);

        // Graph Includes
        // GraphIncludes: <None>

        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif

        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

        // Graph Functions

        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }

        // unity-custom-func-begin
        void FlowUV_float(float FlowSpeed, float Time, float2 UV, float2 FlowVector, out float2 UV1, out float2 UV2, out float Blend){
        float phase0 = Time * FlowSpeed - floor(Time * FlowSpeed);
        float phase1 = (Time * FlowSpeed + 0.5) - floor(Time * FlowSpeed + 0.5);

        UV1 = UV - FlowVector * phase0;
        UV2 = UV - FlowVector * phase1;

        Blend = abs((phase0 - 0.5) * 2.0);
        }
        // unity-custom-func-end

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        struct Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float
        {
        half4 uv0;
        float3 TimeParameters;
        };

        void SG_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float(float _FlowSpeed, float _FlowStrength, UnityTexture2D _FlowMap, UnityTexture2D _WaterTexture, Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float IN, out float4 UV2_2)
        {
        UnityTexture2D _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D = _WaterTexture;
        float _Property_d98c376d1ee546138072a488daec8b4c_Out_0_Float = _FlowSpeed;
        float4 _UV_bf331151e19d4743ac71b3a059904a4a_Out_0_Vector4 = IN.uv0;
        UnityTexture2D _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D = _FlowMap;
        float4 _UV_c10f5674a32049da84c46a321ffdfb6d_Out_0_Vector4 = IN.uv0;
        float4 _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.tex, _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.samplerstate, _Property_f3f630e39b8c4dda878c6ea9f77be86f_Out_0_Texture2D.GetTransformedUV((_UV_c10f5674a32049da84c46a321ffdfb6d_Out_0_Vector4.xy)) );
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_R_4_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.r;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_G_5_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.g;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_B_6_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.b;
        float _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_A_7_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4.a;
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_R_1_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[0];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_G_2_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[1];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_B_3_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[2];
        float _Split_6adf8f8dbcff4b98af7d114ecc255d36_A_4_Float = _SampleTexture2D_5f76795a90e74e94b59f6711c8b3a2e5_RGBA_0_Vector4[3];
        float _Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float;
        Unity_Remap_float(_Split_6adf8f8dbcff4b98af7d114ecc255d36_G_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float);
        float _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float;
        Unity_Remap_float(_Split_6adf8f8dbcff4b98af7d114ecc255d36_R_1_Float, float2 (0, 1), float2 (-1, 1), _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float);
        float2 _Vector2_f223a963e73e447b88759a8aeaf7da92_Out_0_Vector2 = float2(_Remap_a25369dce7a84441a64776b049b4d381_Out_3_Float, _Remap_9938f08b015d4153af1233f264e92eee_Out_3_Float);
        float _Property_8027a7e0aa194e549b8cd3e1219acce4_Out_0_Float = _FlowStrength;
        float2 _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2;
        Unity_Multiply_float2_float2(_Vector2_f223a963e73e447b88759a8aeaf7da92_Out_0_Vector2, (_Property_8027a7e0aa194e549b8cd3e1219acce4_Out_0_Float.xx), _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2);
        float2 _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2;
        float2 _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2;
        float _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float;
        FlowUV_float(_Property_d98c376d1ee546138072a488daec8b4c_Out_0_Float, IN.TimeParameters.x, (_UV_bf331151e19d4743ac71b3a059904a4a_Out_0_Vector4.xy), _Multiply_77a422bbcc5047f6a2d25703771c7ed0_Out_2_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2, _FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float);
        float4 _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.tex, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.samplerstate, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.GetTransformedUV(_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV1_3_Vector2) );
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_R_4_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.r;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_G_5_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.g;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_B_6_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.b;
        float _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_A_7_Float = _SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4.a;
        float4 _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.tex, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.samplerstate, _Property_50e122454d1742f597b0f62896dc54b1_Out_0_Texture2D.GetTransformedUV(_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_UV2_7_Vector2) );
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_R_4_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.r;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_G_5_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.g;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_B_6_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.b;
        float _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_A_7_Float = _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4.a;
        float4 _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4;
        Unity_Lerp_float4(_SampleTexture2D_0cf6768abe484f0f9cfd1ec240380807_RGBA_0_Vector4, _SampleTexture2D_a92c14279bfa4567bdbb40f5a35e02ec_RGBA_0_Vector4, (_FlowUVCustomFunction_ca72b3ef5a0547c49db3e1220c7226df_Blend_8_Float.xxxx), _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4);
        UV2_2 = _Lerp_549b720258f946d9b52cf938d767f548_Out_3_Vector4;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        struct Bindings_DepthFade_fd37366848b771042941ee5121343adf_float
        {
        float4 ScreenPosition;
        float2 NDCPosition;
        };

        void SG_DepthFade_fd37366848b771042941ee5121343adf_float(float _Depth, float _DepthFallOff, Bindings_DepthFade_fd37366848b771042941ee5121343adf_float IN, out float OutVector1_1)
        {
        float _SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float;
        Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float);
        float4 _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4 = IN.ScreenPosition;
        float _Split_4283d983846047c3931269c4f290d4f9_R_1_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[0];
        float _Split_4283d983846047c3931269c4f290d4f9_G_2_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[1];
        float _Split_4283d983846047c3931269c4f290d4f9_B_3_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[2];
        float _Split_4283d983846047c3931269c4f290d4f9_A_4_Float = _ScreenPosition_56ec0fdff9c745afac1467c4a4c06304_Out_0_Vector4[3];
        float _Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float;
        Unity_Subtract_float(_SceneDepth_e71432b3720f4aeeb7aef2e88f4e94d7_Out_1_Float, _Split_4283d983846047c3931269c4f290d4f9_A_4_Float, _Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float);
        float _Property_2376aa4d3f03452fb19c1b6fe12cdd9d_Out_0_Float = _Depth;
        float _Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float;
        Unity_Divide_float(_Subtract_a1d4205483264354b6f4aadf24da47f1_Out_2_Float, _Property_2376aa4d3f03452fb19c1b6fe12cdd9d_Out_0_Float, _Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float);
        float _OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float;
        Unity_OneMinus_float(_Divide_70e55995311b49b2b8b3760e051e2fbe_Out_2_Float, _OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float);
        float _Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float;
        Unity_Saturate_float(_OneMinus_33b5a51e3b2a4d02adc9b08f444c6af9_Out_1_Float, _Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float);
        float _Property_9c8e44da412b47a8a20d93b3cf08bd70_Out_0_Float = _DepthFallOff;
        float _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float;
        Unity_Maximum_float(_Property_9c8e44da412b47a8a20d93b3cf08bd70_Out_0_Float, float(0.005), _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float);
        float _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float;
        Unity_Power_float(_Saturate_c0fc72be409c44f89af387c45cb00bea_Out_1_Float, _Maximum_53f6f9dc73c1432da33ef94ecc0b767b_Out_2_Float, _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float);
        OutVector1_1 = _Power_64d8546a323c4de08ddfff33a5fc37bf_Out_2_Float;
        }

        void Unity_Ceiling_float(float In, out float Out)
        {
            Out = ceil(In);
        }

        struct Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float
        {
        };

        void SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(float _Input, float _Alpha, Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float IN, out float Output_0)
        {
        float _Property_ca30cb36add94aabaa9d9dabfda56c02_Out_0_Float = _Input;
        float _Property_d3832a99da2f48919b2e31df6ee1452a_Out_0_Float = _Alpha;
        float _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float;
        Unity_Saturate_float(_Property_d3832a99da2f48919b2e31df6ee1452a_Out_0_Float, _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float);
        float _Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float;
        Unity_Subtract_float(_Property_ca30cb36add94aabaa9d9dabfda56c02_Out_0_Float, _Saturate_65bc86f130024bd897adc6d070b7ae22_Out_1_Float, _Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float);
        float _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float;
        Unity_Ceiling_float(_Subtract_f1fac5a54017492e8098ecae1721ec74_Out_2_Float, _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float);
        Output_0 = _Ceiling_bb0a810ca29c4e7283aa2167f9109a8c_Out_1_Float;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float = _WaveIntensity;
            float3 _Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3 = float3(float(0), _Property_caca13e667c64fcca3515d9abf95e218_Out_0_Float, float(0));
            float _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float = _WaveSpeed;
            float _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ee1db92d81cc4793a96877e41c718171_Out_0_Float, _Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float);
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_d5e21c4443cb4bf8898afb17ad3e8868_A_4_Float = 0;
            float _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float;
            Unity_Add_float(_Split_d5e21c4443cb4bf8898afb17ad3e8868_R_1_Float, _Split_d5e21c4443cb4bf8898afb17ad3e8868_B_3_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float);
            float _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float;
            Unity_Add_float(_Multiply_fea35f5cc4a64dd38febf9855c413f10_Out_2_Float, _Add_1a01cac0ee4042eb9d6efbd22f4c7117_Out_2_Float, _Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float);
            float _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float;
            Unity_Sine_float(_Add_63ef497e7d6d4f529142313c221f9f24_Out_2_Float, _Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float);
            float3 _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_edb92efc37ef490a84fe31c76338c679_Out_0_Vector3, (_Sine_9e7dbf509fb343b8850b7ff8e839c0a4_Out_1_Float.xxx), _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3);
            float3 _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_337a7c4ef7444097b3f9c6f837f8ca62_Out_2_Vector3, _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3);
            description.Position = _Add_1ff92a15e6d547c89c1b18d1a66fbbd5_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_622f4b00a9ea415788676ffe06990d8e_Out_0_Float = _FlowSpeed;
            float _Property_d81dfb1a7514478f9e84e798877f387f_Out_0_Float = _FlowStrength;
            UnityTexture2D _Property_6f00f50a994a4340bbecb9a1603af3bd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FlowMap);
            UnityTexture2D _Property_3edce890842648a893430eea92089e01_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            Bindings_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd;
            _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd.uv0 = IN.uv0;
            _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd.TimeParameters = IN.TimeParameters;
            float4 _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4;
            SG_FlowMapGraph_ac96c628223561447ade13293daf3c7e_float(_Property_622f4b00a9ea415788676ffe06990d8e_Out_0_Float, _Property_d81dfb1a7514478f9e84e798877f387f_Out_0_Float, _Property_6f00f50a994a4340bbecb9a1603af3bd_Out_0_Texture2D, _Property_3edce890842648a893430eea92089e01_Out_0_Texture2D, _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd, _FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4);
            float4 _Property_6621c89d7b3041c98c7849814df9ca18_Out_0_Vector4 = _FoamColor;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_360d81065f0a4a859a99f08b7011f10a;
            _DepthFade_360d81065f0a4a859a99f08b7011f10a.ScreenPosition = IN.ScreenPosition;
            _DepthFade_360d81065f0a4a859a99f08b7011f10a.NDCPosition = IN.NDCPosition;
            float _DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_360d81065f0a4a859a99f08b7011f10a, _DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float);
            float _Property_e743d6a6031845bebcd1b79a88ad2246_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_32f30c928e1b4a37ae49ec0875a29f14;
            float _CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_360d81065f0a4a859a99f08b7011f10a_OutVector1_1_Float, _Property_e743d6a6031845bebcd1b79a88ad2246_Out_0_Float, _CutOut_32f30c928e1b4a37ae49ec0875a29f14, _CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float);
            UnityTexture2D _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_92eacbf2f91648cdb680cb07b4c84d83_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_c854dcb8c14345c08ccf253c400d0e82_Out_0_Float = _FoamTiling;
            float2 _Property_c0d69e7204734c43812eddc139c336c5_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_c0d69e7204734c43812eddc139c336c5_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2);
            float2 _TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_92eacbf2f91648cdb680cb07b4c84d83_Out_1_Vector2, (_Property_c854dcb8c14345c08ccf253c400d0e82_Out_0_Float.xx), _Multiply_625b25021e414dfeb7c9e17364b839d6_Out_2_Vector2, _TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2);
            float4 _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.tex, _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.samplerstate, _Property_1e06184e38c148e6a99fe6f2edc9c759_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8c525d78786c4a3ba6ff1cc24daf4474_Out_3_Vector2) );
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_R_4_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.r;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_G_5_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.g;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_B_6_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.b;
            float _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_A_7_Float = _SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4.a;
            float _Property_a30767ada2554636b433757722d925a5_Out_0_Float = _FoamDepth;
            float _Property_85a722b2d97c4696b06bd34d41768fc0_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_8253d0b28799460d91b86aaa80bda820;
            _DepthFade_8253d0b28799460d91b86aaa80bda820.ScreenPosition = IN.ScreenPosition;
            _DepthFade_8253d0b28799460d91b86aaa80bda820.NDCPosition = IN.NDCPosition;
            float _DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_a30767ada2554636b433757722d925a5_Out_0_Float, _Property_85a722b2d97c4696b06bd34d41768fc0_Out_0_Float, _DepthFade_8253d0b28799460d91b86aaa80bda820, _DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float);
            float4 _Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_4ea69d24a3014d6886287f42b3bdbdb5_RGBA_0_Vector4, (_DepthFade_8253d0b28799460d91b86aaa80bda820_OutVector1_1_Float.xxxx), _Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4);
            float _Property_e84b809010eb4099a84f1fe170e78493_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_24054a506ba44d258a9324359f9ab56c;
            float _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_c14cad6b759c4d028de178f806255186_Out_2_Vector4).x, _Property_e84b809010eb4099a84f1fe170e78493_Out_0_Float, _CutOut_24054a506ba44d258a9324359f9ab56c, _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float);
            float _Add_3152088544f14edd9b579a71529e5eab_Out_2_Float;
            Unity_Add_float(_CutOut_32f30c928e1b4a37ae49ec0875a29f14_Output_0_Float, _CutOut_24054a506ba44d258a9324359f9ab56c_Output_0_Float, _Add_3152088544f14edd9b579a71529e5eab_Out_2_Float);
            float _Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float;
            Unity_Saturate_float(_Add_3152088544f14edd9b579a71529e5eab_Out_2_Float, _Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float);
            float4 _Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_6621c89d7b3041c98c7849814df9ca18_Out_0_Vector4, (_Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float.xxxx), _Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4);
            float4 _Property_92817ffb792e498491a70743808f9fb4_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_3f698ea5418d4b8a912b10d83ed0ddaf_Out_0_Float = _CausticsTiling;
            float _Property_036faa83e6af4cffb09d74a3bce4b1d4_Out_0_Float = _CausticsSpeed;
            float _Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float;
            Unity_Multiply_float_float(_Property_036faa83e6af4cffb09d74a3bce4b1d4_Out_0_Float, IN.TimeParameters.x, _Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float);
            float2 _TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_3f698ea5418d4b8a912b10d83ed0ddaf_Out_0_Float.xx), (_Multiply_e32d015b0c7140c9b5d90d87a16c431b_Out_2_Float.xx), _TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2);
            float4 _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.tex, _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.samplerstate, _Property_fc5ec1f854c04c768f183f0a5e7c8201_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a3455475dc93426d9b04f41045b63ae9_Out_3_Vector2) );
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_R_4_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.r;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_G_5_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.g;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_B_6_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.b;
            float _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_A_7_Float = _SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4.a;
            UnityTexture2D _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_ae261fa440f7445f9680d4786d9e8d6c_Out_0_Float = _CausticsTiling;
            float _Property_d46424b6f49948c48d8aa5a54e86ab37_Out_0_Float = _CausticsSpeed;
            float _Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float;
            Unity_Multiply_float_float(_Property_d46424b6f49948c48d8aa5a54e86ab37_Out_0_Float, IN.TimeParameters.x, _Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float);
            float _Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_c309dfc1eff64e0fbdc99ffa966077dc_Out_2_Float, -1, _Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float);
            float2 _TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_ae261fa440f7445f9680d4786d9e8d6c_Out_0_Float.xx), (_Multiply_2d3bebac4d03485599e8fb72c18a4dac_Out_2_Float.xx), _TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2);
            float4 _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.tex, _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.samplerstate, _Property_e2f1852e30b347fa9281323dc9e248f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_24cee67382b044eab9839381909496ec_Out_3_Vector2) );
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_R_4_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.r;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_G_5_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.g;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_B_6_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.b;
            float _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_A_7_Float = _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4.a;
            float4 _Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_b94b2e3dffa24c3aaa4ad86dfafb2d7c_RGBA_0_Vector4, _SampleTexture2D_8d30fe23041d4c08b92c4d5f774c2147_RGBA_0_Vector4, _Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4);
            float _Property_ea45466b5ff042dd9d72e0cb76d96729_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dd8e2a36eea948e9b85e89c106e39db9;
            float _CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_370cfb08bd0744e58282fc96ead8df18_Out_2_Vector4).x, _Property_ea45466b5ff042dd9d72e0cb76d96729_Out_0_Float, _CutOut_dd8e2a36eea948e9b85e89c106e39db9, _CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float);
            float4 _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_92817ffb792e498491a70743808f9fb4_Out_0_Vector4, (_CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float.xxxx), _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4);
            float4 _Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4;
            Unity_Add_float4(_Multiply_58608e02865d4e12b1aa4108de3e8549_Out_2_Vector4, _Multiply_cfa12632501b42b1a6766accc43a3f69_Out_2_Vector4, _Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4);
            float _OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float;
            Unity_OneMinus_float(_Saturate_b52ab99b9c1344dbb9d13d02941914c8_Out_1_Float, _OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float);
            float _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float;
            Unity_OneMinus_float(_CutOut_dd8e2a36eea948e9b85e89c106e39db9_Output_0_Float, _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float);
            float _Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float;
            Unity_Add_float(_OneMinus_ff3807fc0feb4e9d8dcc25b201c5bddb_Out_1_Float, _OneMinus_8ff91a7037f142a59f0d2732599dce13_Out_1_Float, _Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float);
            float4 _Property_160f368928724737bd8d235406114282_Out_0_Vector4 = _ShoreColor;
            float _Property_1d8e92e9cd9d411ba17bf254d5c0ac2e_Out_0_Float = _Depth;
            float _Property_a2f1df831feb4ce7a481ba10d6dd5d6e_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7;
            _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7.ScreenPosition = IN.ScreenPosition;
            _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7.NDCPosition = IN.NDCPosition;
            float _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_1d8e92e9cd9d411ba17bf254d5c0ac2e_Out_0_Float, _Property_a2f1df831feb4ce7a481ba10d6dd5d6e_Out_0_Float, _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7, _DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float);
            float4 _Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_160f368928724737bd8d235406114282_Out_0_Vector4, (_DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float.xxxx), _Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4);
            float _OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_e2e0c1a1544344518ed1c67d73a5baf7_OutVector1_1_Float, _OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float);
            float4 _Property_69288d55badb4bc4a9132d27bf2ecfe6_Out_0_Vector4 = _MainColor;
            float4 _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_f0bb487762944f77b4e9e36f70b05b69_Out_1_Float.xxxx), _Property_69288d55badb4bc4a9132d27bf2ecfe6_Out_0_Vector4, _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4);
            float4 _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4;
            Unity_Add_float4(_Multiply_604c72d6fb18467f8a0b7a026597f443_Out_2_Vector4, _Multiply_6941eec202e34a10b16e7caa4afdcecb_Out_2_Vector4, _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4);
            float4 _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_9759c5dc2528409887e77f38f2be2dfe_Out_2_Float.xxxx), _Add_d1261bd427f549928ec95400eb577f24_Out_2_Vector4, _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4);
            float4 _Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4;
            Unity_Add_float4(_Add_f5a9ddc30d8242dbbad8109709d4c21f_Out_2_Vector4, _Multiply_a64a138f55bc4e2fa4232841370e2c38_Out_2_Vector4, _Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4);
            // Second foam ring using Step (hard edge, cartoon style)
            float _SecondFoamTotalWidth = _FoamShoreWidth + _SecondFoamWidth;
            float _DepthFadeShore_SecondFoam;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_360d81065f0a4a859a99f08b7011f10a, _DepthFadeShore_SecondFoam);
            float _Step_SecondFoamOuter = step(_DepthFadeShore_SecondFoam, _SecondFoamTotalWidth);
            float _Step_SecondFoamInner = step(_DepthFadeShore_SecondFoam, _FoamShoreWidth);
            float _SecondFoamMask = saturate(_Step_SecondFoamOuter - _Step_SecondFoamInner);
            float4 _SecondFoamColorValue = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;

            // Lerp: donde hay segundo foam tapa completamente al primero, sin mezcla aditiva
            float4 _Add_WithSecondFoam = lerp(_Add_243f43a18e694b9e967c04992cecb7b3_Out_2_Vector4, _SecondFoamColorValue, _SecondFoamMask);

            float4 _Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4;
            Unity_Add_float4(_FlowMapGraph_a12ea679a8f74cb8823e24f55e6417dd_UV2_2_Vector4, _Add_WithSecondFoam, _Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4);
            surface.BaseColor = (_Add_9abd66c4b7d74619826f9fdab9a89147_Out_2_Vector4.xyz);
            surface.Alpha = float(1);
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif

            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif







            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);

            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif

            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;

            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
        }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif

        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}