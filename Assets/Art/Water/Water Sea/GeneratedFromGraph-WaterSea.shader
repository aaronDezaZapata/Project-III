Shader "Shader Graphs/WaterSea"
{
    Properties
    {
        _Depth("Depth", Float) = 1
        _Depth_1("Depth (1)", Float) = 0
        _Strength("Strength", Range(0, 2)) = 0
        _DeepWaterColor("DeepWaterColor", Color) = (0, 0.3377289, 0.6509434, 0)
        [NoScaleOffset]_MainNormal("MainNormal", 2D) = "white" {}
        [NoScaleOffset]_SecondNormal("SecondNormal", 2D) = "white" {}
        _NormalStrength("NormalStrength", Range(0, 1)) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _Displacement("Displacement", Float) = 0.5
        _WaveSpeedFast("WaveSpeedFast", Float) = 1
        _DepthFallOff("DepthFallOff", Float) = 0
        _MainColor("MainColor", Color) = (0, 0, 0, 0)
        _ShoreColor("ShoreColor", Color) = (0, 0, 0, 0)
        _FoamShoreWidth("FoamShoreWidth", Float) = 0.28
        _FoamColor("FoamColor", Color) = (0, 0, 0, 0)
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
        [HDR]_SecondFoamColor("SecondFoamColor", Color) = (1, 0, 0, 1)
        _SecondFoamWidth("SecondFoamWidth", Float) = 0.3
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
        #define _ALPHATEST_ON 1
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
        float _Depth_1;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
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
        float _Depth;
        float _Strength;
        float4 _DeepWaterColor;
        float4 _MainNormal_TexelSize;
        float4 _SecondNormal_TexelSize;
        float _NormalStrength;
        float _Smoothness;
        float _Displacement;
        float _WaveSpeedFast;
        float4 _SecondFoamColor;
        float _SecondFoamWidth;
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
        TEXTURE2D(_MainNormal);
        SAMPLER(sampler_MainNormal);
        TEXTURE2D(_SecondNormal);
        SAMPLER(sampler_SecondNormal);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
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

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
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
            float _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float = _Displacement;
            float3 _Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3 = float3(float(0), _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float, float(0));
            float _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float = _WaveSpeedFast;
            float _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float, _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float);
            float _Split_fe92c21c18204adebf135b67d8991a97_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_fe92c21c18204adebf135b67d8991a97_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_fe92c21c18204adebf135b67d8991a97_A_4_Float = 0;
            float _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float;
            Unity_Add_float(_Split_fe92c21c18204adebf135b67d8991a97_R_1_Float, _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float);
            float _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float;
            Unity_Add_float(_Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float, _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float);
            float _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float;
            Unity_Sine_float(_Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float, _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float);
            float3 _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3, (_Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float.xxx), _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3);
            float3 _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3, _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3);
            description.Position = _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float = _CausticsTiling;
            float _Property_ec00d672257d4fb187304144345a440d_Out_0_Float = _CausticsSpeed;
            float _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float;
            Unity_Multiply_float_float(_Property_ec00d672257d4fb187304144345a440d_Out_0_Float, IN.TimeParameters.x, _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float);
            float2 _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float.xx), (_Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float.xx), _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2);
            float4 _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.tex, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.samplerstate, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2) );
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_R_4_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.r;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_G_5_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.g;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_B_6_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.b;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_A_7_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.a;
            UnityTexture2D _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float = _CausticsTiling;
            float _Property_96f5ced09471434f906cf522badd752e_Out_0_Float = _CausticsSpeed;
            float _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float;
            Unity_Multiply_float_float(_Property_96f5ced09471434f906cf522badd752e_Out_0_Float, IN.TimeParameters.x, _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float);
            float _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float, -1, _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float);
            float2 _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float.xx), (_Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float.xx), _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2);
            float4 _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.tex, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.samplerstate, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2) );
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_R_4_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.r;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_G_5_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.g;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_B_6_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.b;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_A_7_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.a;
            float4 _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4, _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4, _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4);
            float _Property_65077cd3452749858a92d2d44870f695_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_75220f99a32f45adb650a3e5bbd83f44;
            float _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4).x, _Property_65077cd3452749858a92d2d44870f695_Out_0_Float, _CutOut_75220f99a32f45adb650a3e5bbd83f44, _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float);
            float4 _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4, (_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float.xxxx), _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_ef29a48eac0245c68a177a55dc7cc401;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.ScreenPosition = IN.ScreenPosition;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.NDCPosition = IN.NDCPosition;
            float _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_ef29a48eac0245c68a177a55dc7cc401, _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float);
            float _Property_d216d5543a364030b5a823a82377467d_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_12f43357a8eb4b5eaf77c0402280eea8;
            float _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float, _Property_d216d5543a364030b5a823a82377467d_Out_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float);
            UnityTexture2D _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float = _FoamTiling;
            float2 _Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2);
            float2 _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2, (_Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2, _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2);
            float4 _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.tex, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.samplerstate, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2) );
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_R_4_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.r;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_G_5_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.g;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_B_6_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.b;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_A_7_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.a;
            float _Property_3630b01812814cd1b91e08342a078883_Out_0_Float = _FoamDepth;
            float _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_341daa370cb0407cb1b2907742c8b230;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.ScreenPosition = IN.ScreenPosition;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.NDCPosition = IN.NDCPosition;
            float _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_3630b01812814cd1b91e08342a078883_Out_0_Float, _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float, _DepthFade_341daa370cb0407cb1b2907742c8b230, _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float);
            float4 _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4, (_DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float.xxxx), _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4);
            float _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_203a3ffd185944da95adf1d7aa062e9c;
            float _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4).x, _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float);
            float _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float;
            Unity_Add_float(_CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float, _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float);
            float _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float;
            Unity_Saturate_float(_Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float, _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float);
            float _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float;
            Unity_OneMinus_float(_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float, _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float);
            float _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float;
            Unity_OneMinus_float(_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float);
            float _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float;
            Unity_Add_float(_OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float, _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float);
            float4 _Property_b323242895734c05b718796861d6534b_Out_0_Vector4 = _ShoreColor;
            float _Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float = _Depth;
            float _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.ScreenPosition = IN.ScreenPosition;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.NDCPosition = IN.NDCPosition;
            float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float, _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float);
            float4 _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_b323242895734c05b718796861d6534b_Out_0_Vector4, (_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float.xxxx), _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4);
            float _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float, _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float);
            float4 _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4 = _MainColor;
            float4 _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float.xxxx), _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4);
            float4 _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4, _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4);
            float4 _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float.xxxx), _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4);
            float4 _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4;
            Unity_Add_float4(_Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4, _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4);
            float4 _Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4 = _FoamColor;
            float4 _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4);
            float4 _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4;
            Unity_Lerp_float4(_Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4, _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.ScreenPosition = IN.ScreenPosition;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.NDCPosition = IN.NDCPosition;
            float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d, _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float);
            float _Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float = _FoamShoreWidth;
            float _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float = _SecondFoamWidth;
            float _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float;
            Unity_Add_float(_Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float, _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float);
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dacb55c5015a42f69d937ab9d74411ae;
            float _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float, _CutOut_dacb55c5015a42f69d937ab9d74411ae, _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float);
            float _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float;
            Unity_Subtract_float(_CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float);
            float4 _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;
            float4 _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float.xxxx), _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4);
            float _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float;
            Unity_Saturate_float(_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float, _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float);
            float4 _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4, (_Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float.xxxx), _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4);
            float4 _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4, _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, float4(0, 0, 0, 0), _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4);
            float4 _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float);
            float _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float, _ProjectionParams.z, _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float);
            float4 _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3a3317424ec24fee899b24b01fe24306_R_1_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[0];
            float _Split_3a3317424ec24fee899b24b01fe24306_G_2_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[1];
            float _Split_3a3317424ec24fee899b24b01fe24306_B_3_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[2];
            float _Split_3a3317424ec24fee899b24b01fe24306_A_4_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[3];
            float _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float = _Depth;
            float _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float;
            Unity_Add_float(_Split_3a3317424ec24fee899b24b01fe24306_A_4_Float, _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float);
            float _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float;
            Unity_Subtract_float(_Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float, _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float);
            float _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float = _Strength;
            float _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float, _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float, _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float);
            float _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float;
            Unity_Clamp_float(_Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float, float(0), float(1), _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float);
            float4 _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4, (_Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float.xxxx), _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4);
            float4 _Add_8de99e76051142d0898c23e713d1946f_Out_2_Vector4;
            Unity_Add_float4(_Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4, _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Add_8de99e76051142d0898c23e713d1946f_Out_2_Vector4);
            UnityTexture2D _Property_6206bb9045094f199d3bb88a9c789078_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainNormal);
            float _Divide_f379923a35cc4b798bfebfbf2ecc14d0_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, float(50), _Divide_f379923a35cc4b798bfebfbf2ecc14d0_Out_2_Float);
            float2 _TilingAndOffset_0c55313ba3b14a4dba96b118589504aa_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (50, 50), (_Divide_f379923a35cc4b798bfebfbf2ecc14d0_Out_2_Float.xx), _TilingAndOffset_0c55313ba3b14a4dba96b118589504aa_Out_3_Vector2);
            float4 _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6206bb9045094f199d3bb88a9c789078_Out_0_Texture2D.tex, _Property_6206bb9045094f199d3bb88a9c789078_Out_0_Texture2D.samplerstate, _Property_6206bb9045094f199d3bb88a9c789078_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_0c55313ba3b14a4dba96b118589504aa_Out_3_Vector2) );
            _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4);
            float _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_R_4_Float = _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.r;
            float _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_G_5_Float = _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.g;
            float _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_B_6_Float = _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.b;
            float _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_A_7_Float = _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.a;
            UnityTexture2D _Property_860a72377e9a4588a1b5d23c7a2f22e6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SecondNormal);
            float _Divide_b19dc044dd074f8d9545987bdcaf2133_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, float(-25), _Divide_b19dc044dd074f8d9545987bdcaf2133_Out_2_Float);
            float2 _TilingAndOffset_6560fe27ec974d6c850d89957e24e94e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (50, 50), (_Divide_b19dc044dd074f8d9545987bdcaf2133_Out_2_Float.xx), _TilingAndOffset_6560fe27ec974d6c850d89957e24e94e_Out_3_Vector2);
            float4 _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_860a72377e9a4588a1b5d23c7a2f22e6_Out_0_Texture2D.tex, _Property_860a72377e9a4588a1b5d23c7a2f22e6_Out_0_Texture2D.samplerstate, _Property_860a72377e9a4588a1b5d23c7a2f22e6_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_6560fe27ec974d6c850d89957e24e94e_Out_3_Vector2) );
            _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4);
            float _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_R_4_Float = _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.r;
            float _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_G_5_Float = _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.g;
            float _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_B_6_Float = _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.b;
            float _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_A_7_Float = _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.a;
            float4 _Add_70c297eea1ab41269d3b4dc4f04a0da4_Out_2_Vector4;
            Unity_Add_float4(_SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4, _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4, _Add_70c297eea1ab41269d3b4dc4f04a0da4_Out_2_Vector4);
            float _Property_8987cc5e24df4174a350fbe01c37a6d2_Out_0_Float = _NormalStrength;
            float _Lerp_89ca0902dd664de89e1550a099fa5fa2_Out_3_Float;
            Unity_Lerp_float(float(0), _Property_8987cc5e24df4174a350fbe01c37a6d2_Out_0_Float, _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float, _Lerp_89ca0902dd664de89e1550a099fa5fa2_Out_3_Float);
            float3 _NormalStrength_d0e1cc18540845d191748101b526c1bd_Out_2_Vector3;
            Unity_NormalStrength_float((_Add_70c297eea1ab41269d3b4dc4f04a0da4_Out_2_Vector4.xyz), _Lerp_89ca0902dd664de89e1550a099fa5fa2_Out_3_Float, _NormalStrength_d0e1cc18540845d191748101b526c1bd_Out_2_Vector3);
            float _Property_723db266d7ee4479a040d55fc921a005_Out_0_Float = _Smoothness;
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_R_1_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[0];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_G_2_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[1];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_B_3_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[2];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[3];
            surface.BaseColor = (_Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4.xyz);
            surface.NormalTS = _NormalStrength_d0e1cc18540845d191748101b526c1bd_Out_2_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Smoothness = _Property_723db266d7ee4479a040d55fc921a005_Out_0_Float;
            surface.Occlusion = float(1);
            surface.Alpha = _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float;
            surface.AlphaClipThreshold = float(0);
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
        #define _ALPHATEST_ON 1
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
        float _Depth_1;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
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
        float _Depth;
        float _Strength;
        float4 _DeepWaterColor;
        float4 _MainNormal_TexelSize;
        float4 _SecondNormal_TexelSize;
        float _NormalStrength;
        float _Smoothness;
        float _Displacement;
        float _WaveSpeedFast;
        float4 _SecondFoamColor;
        float _SecondFoamWidth;
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
        TEXTURE2D(_MainNormal);
        SAMPLER(sampler_MainNormal);
        TEXTURE2D(_SecondNormal);
        SAMPLER(sampler_SecondNormal);

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

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
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

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
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
            float _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float = _Displacement;
            float3 _Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3 = float3(float(0), _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float, float(0));
            float _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float = _WaveSpeedFast;
            float _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float, _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float);
            float _Split_fe92c21c18204adebf135b67d8991a97_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_fe92c21c18204adebf135b67d8991a97_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_fe92c21c18204adebf135b67d8991a97_A_4_Float = 0;
            float _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float;
            Unity_Add_float(_Split_fe92c21c18204adebf135b67d8991a97_R_1_Float, _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float);
            float _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float;
            Unity_Add_float(_Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float, _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float);
            float _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float;
            Unity_Sine_float(_Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float, _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float);
            float3 _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3, (_Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float.xxx), _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3);
            float3 _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3, _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3);
            description.Position = _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float = _CausticsTiling;
            float _Property_ec00d672257d4fb187304144345a440d_Out_0_Float = _CausticsSpeed;
            float _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float;
            Unity_Multiply_float_float(_Property_ec00d672257d4fb187304144345a440d_Out_0_Float, IN.TimeParameters.x, _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float);
            float2 _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float.xx), (_Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float.xx), _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2);
            float4 _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.tex, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.samplerstate, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2) );
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_R_4_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.r;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_G_5_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.g;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_B_6_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.b;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_A_7_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.a;
            UnityTexture2D _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float = _CausticsTiling;
            float _Property_96f5ced09471434f906cf522badd752e_Out_0_Float = _CausticsSpeed;
            float _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float;
            Unity_Multiply_float_float(_Property_96f5ced09471434f906cf522badd752e_Out_0_Float, IN.TimeParameters.x, _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float);
            float _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float, -1, _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float);
            float2 _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float.xx), (_Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float.xx), _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2);
            float4 _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.tex, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.samplerstate, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2) );
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_R_4_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.r;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_G_5_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.g;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_B_6_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.b;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_A_7_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.a;
            float4 _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4, _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4, _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4);
            float _Property_65077cd3452749858a92d2d44870f695_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_75220f99a32f45adb650a3e5bbd83f44;
            float _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4).x, _Property_65077cd3452749858a92d2d44870f695_Out_0_Float, _CutOut_75220f99a32f45adb650a3e5bbd83f44, _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float);
            float4 _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4, (_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float.xxxx), _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_ef29a48eac0245c68a177a55dc7cc401;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.ScreenPosition = IN.ScreenPosition;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.NDCPosition = IN.NDCPosition;
            float _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_ef29a48eac0245c68a177a55dc7cc401, _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float);
            float _Property_d216d5543a364030b5a823a82377467d_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_12f43357a8eb4b5eaf77c0402280eea8;
            float _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float, _Property_d216d5543a364030b5a823a82377467d_Out_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float);
            UnityTexture2D _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float = _FoamTiling;
            float2 _Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2);
            float2 _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2, (_Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2, _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2);
            float4 _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.tex, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.samplerstate, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2) );
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_R_4_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.r;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_G_5_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.g;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_B_6_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.b;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_A_7_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.a;
            float _Property_3630b01812814cd1b91e08342a078883_Out_0_Float = _FoamDepth;
            float _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_341daa370cb0407cb1b2907742c8b230;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.ScreenPosition = IN.ScreenPosition;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.NDCPosition = IN.NDCPosition;
            float _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_3630b01812814cd1b91e08342a078883_Out_0_Float, _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float, _DepthFade_341daa370cb0407cb1b2907742c8b230, _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float);
            float4 _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4, (_DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float.xxxx), _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4);
            float _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_203a3ffd185944da95adf1d7aa062e9c;
            float _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4).x, _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float);
            float _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float;
            Unity_Add_float(_CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float, _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float);
            float _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float;
            Unity_Saturate_float(_Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float, _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float);
            float _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float;
            Unity_OneMinus_float(_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float, _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float);
            float _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float;
            Unity_OneMinus_float(_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float);
            float _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float;
            Unity_Add_float(_OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float, _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float);
            float4 _Property_b323242895734c05b718796861d6534b_Out_0_Vector4 = _ShoreColor;
            float _Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float = _Depth;
            float _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.ScreenPosition = IN.ScreenPosition;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.NDCPosition = IN.NDCPosition;
            float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float, _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float);
            float4 _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_b323242895734c05b718796861d6534b_Out_0_Vector4, (_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float.xxxx), _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4);
            float _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float, _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float);
            float4 _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4 = _MainColor;
            float4 _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float.xxxx), _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4);
            float4 _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4, _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4);
            float4 _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float.xxxx), _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4);
            float4 _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4;
            Unity_Add_float4(_Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4, _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4);
            float4 _Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4 = _FoamColor;
            float4 _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4);
            float4 _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4;
            Unity_Lerp_float4(_Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4, _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.ScreenPosition = IN.ScreenPosition;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.NDCPosition = IN.NDCPosition;
            float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d, _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float);
            float _Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float = _FoamShoreWidth;
            float _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float = _SecondFoamWidth;
            float _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float;
            Unity_Add_float(_Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float, _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float);
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dacb55c5015a42f69d937ab9d74411ae;
            float _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float, _CutOut_dacb55c5015a42f69d937ab9d74411ae, _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float);
            float _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float;
            Unity_Subtract_float(_CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float);
            float4 _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;
            float4 _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float.xxxx), _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4);
            float _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float;
            Unity_Saturate_float(_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float, _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float);
            float4 _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4, (_Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float.xxxx), _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4);
            float4 _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4, _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, float4(0, 0, 0, 0), _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4);
            float4 _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float);
            float _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float, _ProjectionParams.z, _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float);
            float4 _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3a3317424ec24fee899b24b01fe24306_R_1_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[0];
            float _Split_3a3317424ec24fee899b24b01fe24306_G_2_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[1];
            float _Split_3a3317424ec24fee899b24b01fe24306_B_3_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[2];
            float _Split_3a3317424ec24fee899b24b01fe24306_A_4_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[3];
            float _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float = _Depth;
            float _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float;
            Unity_Add_float(_Split_3a3317424ec24fee899b24b01fe24306_A_4_Float, _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float);
            float _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float;
            Unity_Subtract_float(_Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float, _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float);
            float _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float = _Strength;
            float _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float, _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float, _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float);
            float _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float;
            Unity_Clamp_float(_Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float, float(0), float(1), _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float);
            float4 _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4, (_Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float.xxxx), _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4);
            float4 _Add_8de99e76051142d0898c23e713d1946f_Out_2_Vector4;
            Unity_Add_float4(_Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4, _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Add_8de99e76051142d0898c23e713d1946f_Out_2_Vector4);
            UnityTexture2D _Property_6206bb9045094f199d3bb88a9c789078_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainNormal);
            float _Divide_f379923a35cc4b798bfebfbf2ecc14d0_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, float(50), _Divide_f379923a35cc4b798bfebfbf2ecc14d0_Out_2_Float);
            float2 _TilingAndOffset_0c55313ba3b14a4dba96b118589504aa_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (50, 50), (_Divide_f379923a35cc4b798bfebfbf2ecc14d0_Out_2_Float.xx), _TilingAndOffset_0c55313ba3b14a4dba96b118589504aa_Out_3_Vector2);
            float4 _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6206bb9045094f199d3bb88a9c789078_Out_0_Texture2D.tex, _Property_6206bb9045094f199d3bb88a9c789078_Out_0_Texture2D.samplerstate, _Property_6206bb9045094f199d3bb88a9c789078_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_0c55313ba3b14a4dba96b118589504aa_Out_3_Vector2) );
            _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4);
            float _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_R_4_Float = _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.r;
            float _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_G_5_Float = _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.g;
            float _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_B_6_Float = _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.b;
            float _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_A_7_Float = _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.a;
            UnityTexture2D _Property_860a72377e9a4588a1b5d23c7a2f22e6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SecondNormal);
            float _Divide_b19dc044dd074f8d9545987bdcaf2133_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, float(-25), _Divide_b19dc044dd074f8d9545987bdcaf2133_Out_2_Float);
            float2 _TilingAndOffset_6560fe27ec974d6c850d89957e24e94e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (50, 50), (_Divide_b19dc044dd074f8d9545987bdcaf2133_Out_2_Float.xx), _TilingAndOffset_6560fe27ec974d6c850d89957e24e94e_Out_3_Vector2);
            float4 _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_860a72377e9a4588a1b5d23c7a2f22e6_Out_0_Texture2D.tex, _Property_860a72377e9a4588a1b5d23c7a2f22e6_Out_0_Texture2D.samplerstate, _Property_860a72377e9a4588a1b5d23c7a2f22e6_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_6560fe27ec974d6c850d89957e24e94e_Out_3_Vector2) );
            _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4);
            float _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_R_4_Float = _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.r;
            float _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_G_5_Float = _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.g;
            float _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_B_6_Float = _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.b;
            float _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_A_7_Float = _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.a;
            float4 _Add_70c297eea1ab41269d3b4dc4f04a0da4_Out_2_Vector4;
            Unity_Add_float4(_SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4, _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4, _Add_70c297eea1ab41269d3b4dc4f04a0da4_Out_2_Vector4);
            float _Property_8987cc5e24df4174a350fbe01c37a6d2_Out_0_Float = _NormalStrength;
            float _Lerp_89ca0902dd664de89e1550a099fa5fa2_Out_3_Float;
            Unity_Lerp_float(float(0), _Property_8987cc5e24df4174a350fbe01c37a6d2_Out_0_Float, _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float, _Lerp_89ca0902dd664de89e1550a099fa5fa2_Out_3_Float);
            float3 _NormalStrength_d0e1cc18540845d191748101b526c1bd_Out_2_Vector3;
            Unity_NormalStrength_float((_Add_70c297eea1ab41269d3b4dc4f04a0da4_Out_2_Vector4.xyz), _Lerp_89ca0902dd664de89e1550a099fa5fa2_Out_3_Float, _NormalStrength_d0e1cc18540845d191748101b526c1bd_Out_2_Vector3);
            float _Property_723db266d7ee4479a040d55fc921a005_Out_0_Float = _Smoothness;
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_R_1_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[0];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_G_2_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[1];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_B_3_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[2];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[3];
            surface.BaseColor = (_Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4.xyz);
            surface.NormalTS = _NormalStrength_d0e1cc18540845d191748101b526c1bd_Out_2_Vector3;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Smoothness = _Property_723db266d7ee4479a040d55fc921a005_Out_0_Float;
            surface.Occlusion = float(1);
            surface.Alpha = _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float;
            surface.AlphaClipThreshold = float(0);
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
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE


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
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
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
             float3 normalWS : INTERP2;
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
            output.texCoord0 = input.texCoord0.xyzw;
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
        float _Depth_1;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
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
        float _Depth;
        float _Strength;
        float4 _DeepWaterColor;
        float4 _MainNormal_TexelSize;
        float4 _SecondNormal_TexelSize;
        float _NormalStrength;
        float _Smoothness;
        float _Displacement;
        float _WaveSpeedFast;
        float4 _SecondFoamColor;
        float _SecondFoamWidth;
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
        TEXTURE2D(_MainNormal);
        SAMPLER(sampler_MainNormal);
        TEXTURE2D(_SecondNormal);
        SAMPLER(sampler_SecondNormal);

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

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
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

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
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
            float _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float = _Displacement;
            float3 _Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3 = float3(float(0), _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float, float(0));
            float _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float = _WaveSpeedFast;
            float _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float, _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float);
            float _Split_fe92c21c18204adebf135b67d8991a97_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_fe92c21c18204adebf135b67d8991a97_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_fe92c21c18204adebf135b67d8991a97_A_4_Float = 0;
            float _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float;
            Unity_Add_float(_Split_fe92c21c18204adebf135b67d8991a97_R_1_Float, _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float);
            float _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float;
            Unity_Add_float(_Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float, _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float);
            float _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float;
            Unity_Sine_float(_Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float, _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float);
            float3 _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3, (_Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float.xxx), _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3);
            float3 _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3, _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3);
            description.Position = _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float = _CausticsTiling;
            float _Property_ec00d672257d4fb187304144345a440d_Out_0_Float = _CausticsSpeed;
            float _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float;
            Unity_Multiply_float_float(_Property_ec00d672257d4fb187304144345a440d_Out_0_Float, IN.TimeParameters.x, _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float);
            float2 _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float.xx), (_Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float.xx), _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2);
            float4 _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.tex, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.samplerstate, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2) );
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_R_4_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.r;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_G_5_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.g;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_B_6_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.b;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_A_7_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.a;
            UnityTexture2D _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float = _CausticsTiling;
            float _Property_96f5ced09471434f906cf522badd752e_Out_0_Float = _CausticsSpeed;
            float _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float;
            Unity_Multiply_float_float(_Property_96f5ced09471434f906cf522badd752e_Out_0_Float, IN.TimeParameters.x, _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float);
            float _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float, -1, _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float);
            float2 _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float.xx), (_Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float.xx), _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2);
            float4 _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.tex, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.samplerstate, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2) );
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_R_4_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.r;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_G_5_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.g;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_B_6_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.b;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_A_7_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.a;
            float4 _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4, _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4, _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4);
            float _Property_65077cd3452749858a92d2d44870f695_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_75220f99a32f45adb650a3e5bbd83f44;
            float _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4).x, _Property_65077cd3452749858a92d2d44870f695_Out_0_Float, _CutOut_75220f99a32f45adb650a3e5bbd83f44, _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float);
            float4 _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4, (_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float.xxxx), _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_ef29a48eac0245c68a177a55dc7cc401;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.ScreenPosition = IN.ScreenPosition;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.NDCPosition = IN.NDCPosition;
            float _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_ef29a48eac0245c68a177a55dc7cc401, _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float);
            float _Property_d216d5543a364030b5a823a82377467d_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_12f43357a8eb4b5eaf77c0402280eea8;
            float _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float, _Property_d216d5543a364030b5a823a82377467d_Out_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float);
            UnityTexture2D _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float = _FoamTiling;
            float2 _Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2);
            float2 _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2, (_Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2, _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2);
            float4 _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.tex, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.samplerstate, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2) );
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_R_4_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.r;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_G_5_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.g;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_B_6_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.b;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_A_7_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.a;
            float _Property_3630b01812814cd1b91e08342a078883_Out_0_Float = _FoamDepth;
            float _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_341daa370cb0407cb1b2907742c8b230;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.ScreenPosition = IN.ScreenPosition;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.NDCPosition = IN.NDCPosition;
            float _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_3630b01812814cd1b91e08342a078883_Out_0_Float, _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float, _DepthFade_341daa370cb0407cb1b2907742c8b230, _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float);
            float4 _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4, (_DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float.xxxx), _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4);
            float _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_203a3ffd185944da95adf1d7aa062e9c;
            float _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4).x, _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float);
            float _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float;
            Unity_Add_float(_CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float, _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float);
            float _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float;
            Unity_Saturate_float(_Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float, _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float);
            float _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float;
            Unity_OneMinus_float(_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float, _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float);
            float _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float;
            Unity_OneMinus_float(_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float);
            float _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float;
            Unity_Add_float(_OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float, _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float);
            float4 _Property_b323242895734c05b718796861d6534b_Out_0_Vector4 = _ShoreColor;
            float _Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float = _Depth;
            float _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.ScreenPosition = IN.ScreenPosition;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.NDCPosition = IN.NDCPosition;
            float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float, _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float);
            float4 _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_b323242895734c05b718796861d6534b_Out_0_Vector4, (_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float.xxxx), _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4);
            float _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float, _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float);
            float4 _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4 = _MainColor;
            float4 _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float.xxxx), _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4);
            float4 _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4, _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4);
            float4 _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float.xxxx), _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4);
            float4 _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4;
            Unity_Add_float4(_Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4, _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4);
            float4 _Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4 = _FoamColor;
            float4 _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4);
            float4 _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4;
            Unity_Lerp_float4(_Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4, _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.ScreenPosition = IN.ScreenPosition;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.NDCPosition = IN.NDCPosition;
            float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d, _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float);
            float _Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float = _FoamShoreWidth;
            float _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float = _SecondFoamWidth;
            float _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float;
            Unity_Add_float(_Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float, _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float);
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dacb55c5015a42f69d937ab9d74411ae;
            float _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float, _CutOut_dacb55c5015a42f69d937ab9d74411ae, _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float);
            float _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float;
            Unity_Subtract_float(_CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float);
            float4 _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;
            float4 _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float.xxxx), _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4);
            float _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float;
            Unity_Saturate_float(_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float, _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float);
            float4 _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4, (_Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float.xxxx), _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4);
            float4 _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4, _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, float4(0, 0, 0, 0), _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4);
            float4 _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float);
            float _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float, _ProjectionParams.z, _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float);
            float4 _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3a3317424ec24fee899b24b01fe24306_R_1_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[0];
            float _Split_3a3317424ec24fee899b24b01fe24306_G_2_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[1];
            float _Split_3a3317424ec24fee899b24b01fe24306_B_3_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[2];
            float _Split_3a3317424ec24fee899b24b01fe24306_A_4_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[3];
            float _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float = _Depth;
            float _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float;
            Unity_Add_float(_Split_3a3317424ec24fee899b24b01fe24306_A_4_Float, _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float);
            float _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float;
            Unity_Subtract_float(_Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float, _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float);
            float _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float = _Strength;
            float _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float, _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float, _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float);
            float _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float;
            Unity_Clamp_float(_Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float, float(0), float(1), _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float);
            float4 _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4, (_Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float.xxxx), _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4);
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_R_1_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[0];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_G_2_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[1];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_B_3_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[2];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[3];
            surface.Alpha = _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float;
            surface.AlphaClipThreshold = float(0);
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
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE


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
        float _Depth_1;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
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
        float _Depth;
        float _Strength;
        float4 _DeepWaterColor;
        float4 _MainNormal_TexelSize;
        float4 _SecondNormal_TexelSize;
        float _NormalStrength;
        float _Smoothness;
        float _Displacement;
        float _WaveSpeedFast;
        float4 _SecondFoamColor;
        float _SecondFoamWidth;
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
        TEXTURE2D(_MainNormal);
        SAMPLER(sampler_MainNormal);
        TEXTURE2D(_SecondNormal);
        SAMPLER(sampler_SecondNormal);

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

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
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

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
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
            float _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float = _Displacement;
            float3 _Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3 = float3(float(0), _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float, float(0));
            float _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float = _WaveSpeedFast;
            float _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float, _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float);
            float _Split_fe92c21c18204adebf135b67d8991a97_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_fe92c21c18204adebf135b67d8991a97_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_fe92c21c18204adebf135b67d8991a97_A_4_Float = 0;
            float _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float;
            Unity_Add_float(_Split_fe92c21c18204adebf135b67d8991a97_R_1_Float, _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float);
            float _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float;
            Unity_Add_float(_Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float, _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float);
            float _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float;
            Unity_Sine_float(_Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float, _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float);
            float3 _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3, (_Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float.xxx), _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3);
            float3 _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3, _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3);
            description.Position = _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float = _CausticsTiling;
            float _Property_ec00d672257d4fb187304144345a440d_Out_0_Float = _CausticsSpeed;
            float _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float;
            Unity_Multiply_float_float(_Property_ec00d672257d4fb187304144345a440d_Out_0_Float, IN.TimeParameters.x, _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float);
            float2 _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float.xx), (_Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float.xx), _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2);
            float4 _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.tex, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.samplerstate, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2) );
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_R_4_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.r;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_G_5_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.g;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_B_6_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.b;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_A_7_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.a;
            UnityTexture2D _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float = _CausticsTiling;
            float _Property_96f5ced09471434f906cf522badd752e_Out_0_Float = _CausticsSpeed;
            float _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float;
            Unity_Multiply_float_float(_Property_96f5ced09471434f906cf522badd752e_Out_0_Float, IN.TimeParameters.x, _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float);
            float _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float, -1, _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float);
            float2 _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float.xx), (_Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float.xx), _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2);
            float4 _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.tex, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.samplerstate, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2) );
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_R_4_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.r;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_G_5_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.g;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_B_6_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.b;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_A_7_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.a;
            float4 _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4, _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4, _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4);
            float _Property_65077cd3452749858a92d2d44870f695_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_75220f99a32f45adb650a3e5bbd83f44;
            float _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4).x, _Property_65077cd3452749858a92d2d44870f695_Out_0_Float, _CutOut_75220f99a32f45adb650a3e5bbd83f44, _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float);
            float4 _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4, (_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float.xxxx), _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_ef29a48eac0245c68a177a55dc7cc401;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.ScreenPosition = IN.ScreenPosition;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.NDCPosition = IN.NDCPosition;
            float _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_ef29a48eac0245c68a177a55dc7cc401, _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float);
            float _Property_d216d5543a364030b5a823a82377467d_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_12f43357a8eb4b5eaf77c0402280eea8;
            float _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float, _Property_d216d5543a364030b5a823a82377467d_Out_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float);
            UnityTexture2D _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float = _FoamTiling;
            float2 _Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2);
            float2 _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2, (_Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2, _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2);
            float4 _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.tex, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.samplerstate, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2) );
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_R_4_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.r;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_G_5_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.g;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_B_6_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.b;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_A_7_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.a;
            float _Property_3630b01812814cd1b91e08342a078883_Out_0_Float = _FoamDepth;
            float _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_341daa370cb0407cb1b2907742c8b230;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.ScreenPosition = IN.ScreenPosition;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.NDCPosition = IN.NDCPosition;
            float _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_3630b01812814cd1b91e08342a078883_Out_0_Float, _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float, _DepthFade_341daa370cb0407cb1b2907742c8b230, _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float);
            float4 _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4, (_DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float.xxxx), _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4);
            float _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_203a3ffd185944da95adf1d7aa062e9c;
            float _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4).x, _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float);
            float _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float;
            Unity_Add_float(_CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float, _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float);
            float _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float;
            Unity_Saturate_float(_Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float, _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float);
            float _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float;
            Unity_OneMinus_float(_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float, _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float);
            float _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float;
            Unity_OneMinus_float(_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float);
            float _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float;
            Unity_Add_float(_OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float, _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float);
            float4 _Property_b323242895734c05b718796861d6534b_Out_0_Vector4 = _ShoreColor;
            float _Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float = _Depth;
            float _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.ScreenPosition = IN.ScreenPosition;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.NDCPosition = IN.NDCPosition;
            float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float, _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float);
            float4 _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_b323242895734c05b718796861d6534b_Out_0_Vector4, (_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float.xxxx), _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4);
            float _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float, _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float);
            float4 _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4 = _MainColor;
            float4 _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float.xxxx), _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4);
            float4 _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4, _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4);
            float4 _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float.xxxx), _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4);
            float4 _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4;
            Unity_Add_float4(_Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4, _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4);
            float4 _Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4 = _FoamColor;
            float4 _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4);
            float4 _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4;
            Unity_Lerp_float4(_Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4, _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.ScreenPosition = IN.ScreenPosition;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.NDCPosition = IN.NDCPosition;
            float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d, _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float);
            float _Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float = _FoamShoreWidth;
            float _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float = _SecondFoamWidth;
            float _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float;
            Unity_Add_float(_Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float, _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float);
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dacb55c5015a42f69d937ab9d74411ae;
            float _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float, _CutOut_dacb55c5015a42f69d937ab9d74411ae, _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float);
            float _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float;
            Unity_Subtract_float(_CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float);
            float4 _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;
            float4 _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float.xxxx), _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4);
            float _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float;
            Unity_Saturate_float(_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float, _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float);
            float4 _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4, (_Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float.xxxx), _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4);
            float4 _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4, _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, float4(0, 0, 0, 0), _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4);
            float4 _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float);
            float _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float, _ProjectionParams.z, _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float);
            float4 _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3a3317424ec24fee899b24b01fe24306_R_1_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[0];
            float _Split_3a3317424ec24fee899b24b01fe24306_G_2_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[1];
            float _Split_3a3317424ec24fee899b24b01fe24306_B_3_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[2];
            float _Split_3a3317424ec24fee899b24b01fe24306_A_4_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[3];
            float _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float = _Depth;
            float _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float;
            Unity_Add_float(_Split_3a3317424ec24fee899b24b01fe24306_A_4_Float, _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float);
            float _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float;
            Unity_Subtract_float(_Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float, _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float);
            float _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float = _Strength;
            float _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float, _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float, _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float);
            float _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float;
            Unity_Clamp_float(_Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float, float(0), float(1), _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float);
            float4 _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4, (_Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float.xxxx), _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4);
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_R_1_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[0];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_G_2_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[1];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_B_3_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[2];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[3];
            surface.Alpha = _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float;
            surface.AlphaClipThreshold = float(0);
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
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE


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
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
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
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
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
            output.texCoord0.xyzw = input.texCoord0;
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
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
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
        float _Depth_1;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
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
        float _Depth;
        float _Strength;
        float4 _DeepWaterColor;
        float4 _MainNormal_TexelSize;
        float4 _SecondNormal_TexelSize;
        float _NormalStrength;
        float _Smoothness;
        float _Displacement;
        float _WaveSpeedFast;
        float4 _SecondFoamColor;
        float _SecondFoamWidth;
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
        TEXTURE2D(_MainNormal);
        SAMPLER(sampler_MainNormal);
        TEXTURE2D(_SecondNormal);
        SAMPLER(sampler_SecondNormal);

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

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
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

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
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

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
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
            float _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float = _Displacement;
            float3 _Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3 = float3(float(0), _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float, float(0));
            float _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float = _WaveSpeedFast;
            float _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float, _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float);
            float _Split_fe92c21c18204adebf135b67d8991a97_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_fe92c21c18204adebf135b67d8991a97_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_fe92c21c18204adebf135b67d8991a97_A_4_Float = 0;
            float _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float;
            Unity_Add_float(_Split_fe92c21c18204adebf135b67d8991a97_R_1_Float, _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float);
            float _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float;
            Unity_Add_float(_Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float, _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float);
            float _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float;
            Unity_Sine_float(_Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float, _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float);
            float3 _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3, (_Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float.xxx), _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3);
            float3 _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3, _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3);
            description.Position = _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_6206bb9045094f199d3bb88a9c789078_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainNormal);
            float _Divide_f379923a35cc4b798bfebfbf2ecc14d0_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, float(50), _Divide_f379923a35cc4b798bfebfbf2ecc14d0_Out_2_Float);
            float2 _TilingAndOffset_0c55313ba3b14a4dba96b118589504aa_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (50, 50), (_Divide_f379923a35cc4b798bfebfbf2ecc14d0_Out_2_Float.xx), _TilingAndOffset_0c55313ba3b14a4dba96b118589504aa_Out_3_Vector2);
            float4 _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6206bb9045094f199d3bb88a9c789078_Out_0_Texture2D.tex, _Property_6206bb9045094f199d3bb88a9c789078_Out_0_Texture2D.samplerstate, _Property_6206bb9045094f199d3bb88a9c789078_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_0c55313ba3b14a4dba96b118589504aa_Out_3_Vector2) );
            _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4);
            float _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_R_4_Float = _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.r;
            float _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_G_5_Float = _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.g;
            float _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_B_6_Float = _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.b;
            float _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_A_7_Float = _SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4.a;
            UnityTexture2D _Property_860a72377e9a4588a1b5d23c7a2f22e6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_SecondNormal);
            float _Divide_b19dc044dd074f8d9545987bdcaf2133_Out_2_Float;
            Unity_Divide_float(IN.TimeParameters.x, float(-25), _Divide_b19dc044dd074f8d9545987bdcaf2133_Out_2_Float);
            float2 _TilingAndOffset_6560fe27ec974d6c850d89957e24e94e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (50, 50), (_Divide_b19dc044dd074f8d9545987bdcaf2133_Out_2_Float.xx), _TilingAndOffset_6560fe27ec974d6c850d89957e24e94e_Out_3_Vector2);
            float4 _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_860a72377e9a4588a1b5d23c7a2f22e6_Out_0_Texture2D.tex, _Property_860a72377e9a4588a1b5d23c7a2f22e6_Out_0_Texture2D.samplerstate, _Property_860a72377e9a4588a1b5d23c7a2f22e6_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_6560fe27ec974d6c850d89957e24e94e_Out_3_Vector2) );
            _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4);
            float _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_R_4_Float = _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.r;
            float _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_G_5_Float = _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.g;
            float _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_B_6_Float = _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.b;
            float _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_A_7_Float = _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4.a;
            float4 _Add_70c297eea1ab41269d3b4dc4f04a0da4_Out_2_Vector4;
            Unity_Add_float4(_SampleTexture2D_de2f6e62435e4cd3b99cfce89a093020_RGBA_0_Vector4, _SampleTexture2D_1abee9a2ca3e4b8d995f371e0d55720a_RGBA_0_Vector4, _Add_70c297eea1ab41269d3b4dc4f04a0da4_Out_2_Vector4);
            float _Property_8987cc5e24df4174a350fbe01c37a6d2_Out_0_Float = _NormalStrength;
            float _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float);
            float _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float, _ProjectionParams.z, _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float);
            float4 _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3a3317424ec24fee899b24b01fe24306_R_1_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[0];
            float _Split_3a3317424ec24fee899b24b01fe24306_G_2_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[1];
            float _Split_3a3317424ec24fee899b24b01fe24306_B_3_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[2];
            float _Split_3a3317424ec24fee899b24b01fe24306_A_4_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[3];
            float _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float = _Depth;
            float _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float;
            Unity_Add_float(_Split_3a3317424ec24fee899b24b01fe24306_A_4_Float, _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float);
            float _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float;
            Unity_Subtract_float(_Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float, _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float);
            float _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float = _Strength;
            float _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float, _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float, _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float);
            float _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float;
            Unity_Clamp_float(_Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float, float(0), float(1), _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float);
            float _Lerp_89ca0902dd664de89e1550a099fa5fa2_Out_3_Float;
            Unity_Lerp_float(float(0), _Property_8987cc5e24df4174a350fbe01c37a6d2_Out_0_Float, _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float, _Lerp_89ca0902dd664de89e1550a099fa5fa2_Out_3_Float);
            float3 _NormalStrength_d0e1cc18540845d191748101b526c1bd_Out_2_Vector3;
            Unity_NormalStrength_float((_Add_70c297eea1ab41269d3b4dc4f04a0da4_Out_2_Vector4.xyz), _Lerp_89ca0902dd664de89e1550a099fa5fa2_Out_3_Float, _NormalStrength_d0e1cc18540845d191748101b526c1bd_Out_2_Vector3);
            float4 _Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float = _CausticsTiling;
            float _Property_ec00d672257d4fb187304144345a440d_Out_0_Float = _CausticsSpeed;
            float _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float;
            Unity_Multiply_float_float(_Property_ec00d672257d4fb187304144345a440d_Out_0_Float, IN.TimeParameters.x, _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float);
            float2 _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float.xx), (_Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float.xx), _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2);
            float4 _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.tex, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.samplerstate, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2) );
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_R_4_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.r;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_G_5_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.g;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_B_6_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.b;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_A_7_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.a;
            UnityTexture2D _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float = _CausticsTiling;
            float _Property_96f5ced09471434f906cf522badd752e_Out_0_Float = _CausticsSpeed;
            float _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float;
            Unity_Multiply_float_float(_Property_96f5ced09471434f906cf522badd752e_Out_0_Float, IN.TimeParameters.x, _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float);
            float _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float, -1, _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float);
            float2 _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float.xx), (_Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float.xx), _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2);
            float4 _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.tex, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.samplerstate, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2) );
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_R_4_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.r;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_G_5_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.g;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_B_6_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.b;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_A_7_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.a;
            float4 _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4, _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4, _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4);
            float _Property_65077cd3452749858a92d2d44870f695_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_75220f99a32f45adb650a3e5bbd83f44;
            float _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4).x, _Property_65077cd3452749858a92d2d44870f695_Out_0_Float, _CutOut_75220f99a32f45adb650a3e5bbd83f44, _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float);
            float4 _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4, (_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float.xxxx), _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_ef29a48eac0245c68a177a55dc7cc401;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.ScreenPosition = IN.ScreenPosition;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.NDCPosition = IN.NDCPosition;
            float _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_ef29a48eac0245c68a177a55dc7cc401, _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float);
            float _Property_d216d5543a364030b5a823a82377467d_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_12f43357a8eb4b5eaf77c0402280eea8;
            float _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float, _Property_d216d5543a364030b5a823a82377467d_Out_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float);
            UnityTexture2D _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float = _FoamTiling;
            float2 _Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2);
            float2 _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2, (_Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2, _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2);
            float4 _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.tex, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.samplerstate, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2) );
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_R_4_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.r;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_G_5_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.g;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_B_6_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.b;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_A_7_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.a;
            float _Property_3630b01812814cd1b91e08342a078883_Out_0_Float = _FoamDepth;
            float _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_341daa370cb0407cb1b2907742c8b230;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.ScreenPosition = IN.ScreenPosition;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.NDCPosition = IN.NDCPosition;
            float _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_3630b01812814cd1b91e08342a078883_Out_0_Float, _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float, _DepthFade_341daa370cb0407cb1b2907742c8b230, _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float);
            float4 _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4, (_DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float.xxxx), _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4);
            float _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_203a3ffd185944da95adf1d7aa062e9c;
            float _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4).x, _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float);
            float _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float;
            Unity_Add_float(_CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float, _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float);
            float _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float;
            Unity_Saturate_float(_Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float, _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float);
            float _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float;
            Unity_OneMinus_float(_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float, _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float);
            float _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float;
            Unity_OneMinus_float(_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float);
            float _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float;
            Unity_Add_float(_OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float, _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float);
            float4 _Property_b323242895734c05b718796861d6534b_Out_0_Vector4 = _ShoreColor;
            float _Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float = _Depth;
            float _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.ScreenPosition = IN.ScreenPosition;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.NDCPosition = IN.NDCPosition;
            float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float, _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float);
            float4 _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_b323242895734c05b718796861d6534b_Out_0_Vector4, (_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float.xxxx), _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4);
            float _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float, _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float);
            float4 _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4 = _MainColor;
            float4 _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float.xxxx), _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4);
            float4 _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4, _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4);
            float4 _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float.xxxx), _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4);
            float4 _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4;
            Unity_Add_float4(_Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4, _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4);
            float4 _Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4 = _FoamColor;
            float4 _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4);
            float4 _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4;
            Unity_Lerp_float4(_Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4, _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.ScreenPosition = IN.ScreenPosition;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.NDCPosition = IN.NDCPosition;
            float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d, _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float);
            float _Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float = _FoamShoreWidth;
            float _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float = _SecondFoamWidth;
            float _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float;
            Unity_Add_float(_Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float, _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float);
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dacb55c5015a42f69d937ab9d74411ae;
            float _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float, _CutOut_dacb55c5015a42f69d937ab9d74411ae, _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float);
            float _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float;
            Unity_Subtract_float(_CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float);
            float4 _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;
            float4 _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float.xxxx), _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4);
            float _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float;
            Unity_Saturate_float(_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float, _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float);
            float4 _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4, (_Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float.xxxx), _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4);
            float4 _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4, _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, float4(0, 0, 0, 0), _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4);
            float4 _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4 = _DeepWaterColor;
            float4 _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4, (_Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float.xxxx), _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4);
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_R_1_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[0];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_G_2_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[1];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_B_3_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[2];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[3];
            surface.NormalTS = _NormalStrength_d0e1cc18540845d191748101b526c1bd_Out_2_Vector3;
            surface.Alpha = _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float;
            surface.AlphaClipThreshold = float(0);
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
        #define _ALPHATEST_ON 1
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
        float _Depth_1;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
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
        float _Depth;
        float _Strength;
        float4 _DeepWaterColor;
        float4 _MainNormal_TexelSize;
        float4 _SecondNormal_TexelSize;
        float _NormalStrength;
        float _Smoothness;
        float _Displacement;
        float _WaveSpeedFast;
        float4 _SecondFoamColor;
        float _SecondFoamWidth;
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
        TEXTURE2D(_MainNormal);
        SAMPLER(sampler_MainNormal);
        TEXTURE2D(_SecondNormal);
        SAMPLER(sampler_SecondNormal);

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

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
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

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
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
            float _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float = _Displacement;
            float3 _Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3 = float3(float(0), _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float, float(0));
            float _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float = _WaveSpeedFast;
            float _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float, _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float);
            float _Split_fe92c21c18204adebf135b67d8991a97_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_fe92c21c18204adebf135b67d8991a97_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_fe92c21c18204adebf135b67d8991a97_A_4_Float = 0;
            float _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float;
            Unity_Add_float(_Split_fe92c21c18204adebf135b67d8991a97_R_1_Float, _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float);
            float _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float;
            Unity_Add_float(_Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float, _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float);
            float _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float;
            Unity_Sine_float(_Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float, _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float);
            float3 _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3, (_Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float.xxx), _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3);
            float3 _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3, _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3);
            description.Position = _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float = _CausticsTiling;
            float _Property_ec00d672257d4fb187304144345a440d_Out_0_Float = _CausticsSpeed;
            float _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float;
            Unity_Multiply_float_float(_Property_ec00d672257d4fb187304144345a440d_Out_0_Float, IN.TimeParameters.x, _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float);
            float2 _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float.xx), (_Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float.xx), _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2);
            float4 _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.tex, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.samplerstate, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2) );
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_R_4_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.r;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_G_5_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.g;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_B_6_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.b;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_A_7_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.a;
            UnityTexture2D _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float = _CausticsTiling;
            float _Property_96f5ced09471434f906cf522badd752e_Out_0_Float = _CausticsSpeed;
            float _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float;
            Unity_Multiply_float_float(_Property_96f5ced09471434f906cf522badd752e_Out_0_Float, IN.TimeParameters.x, _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float);
            float _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float, -1, _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float);
            float2 _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float.xx), (_Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float.xx), _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2);
            float4 _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.tex, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.samplerstate, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2) );
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_R_4_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.r;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_G_5_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.g;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_B_6_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.b;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_A_7_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.a;
            float4 _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4, _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4, _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4);
            float _Property_65077cd3452749858a92d2d44870f695_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_75220f99a32f45adb650a3e5bbd83f44;
            float _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4).x, _Property_65077cd3452749858a92d2d44870f695_Out_0_Float, _CutOut_75220f99a32f45adb650a3e5bbd83f44, _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float);
            float4 _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4, (_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float.xxxx), _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_ef29a48eac0245c68a177a55dc7cc401;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.ScreenPosition = IN.ScreenPosition;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.NDCPosition = IN.NDCPosition;
            float _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_ef29a48eac0245c68a177a55dc7cc401, _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float);
            float _Property_d216d5543a364030b5a823a82377467d_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_12f43357a8eb4b5eaf77c0402280eea8;
            float _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float, _Property_d216d5543a364030b5a823a82377467d_Out_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float);
            UnityTexture2D _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float = _FoamTiling;
            float2 _Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2);
            float2 _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2, (_Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2, _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2);
            float4 _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.tex, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.samplerstate, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2) );
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_R_4_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.r;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_G_5_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.g;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_B_6_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.b;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_A_7_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.a;
            float _Property_3630b01812814cd1b91e08342a078883_Out_0_Float = _FoamDepth;
            float _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_341daa370cb0407cb1b2907742c8b230;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.ScreenPosition = IN.ScreenPosition;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.NDCPosition = IN.NDCPosition;
            float _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_3630b01812814cd1b91e08342a078883_Out_0_Float, _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float, _DepthFade_341daa370cb0407cb1b2907742c8b230, _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float);
            float4 _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4, (_DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float.xxxx), _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4);
            float _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_203a3ffd185944da95adf1d7aa062e9c;
            float _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4).x, _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float);
            float _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float;
            Unity_Add_float(_CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float, _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float);
            float _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float;
            Unity_Saturate_float(_Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float, _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float);
            float _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float;
            Unity_OneMinus_float(_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float, _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float);
            float _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float;
            Unity_OneMinus_float(_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float);
            float _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float;
            Unity_Add_float(_OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float, _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float);
            float4 _Property_b323242895734c05b718796861d6534b_Out_0_Vector4 = _ShoreColor;
            float _Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float = _Depth;
            float _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.ScreenPosition = IN.ScreenPosition;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.NDCPosition = IN.NDCPosition;
            float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float, _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float);
            float4 _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_b323242895734c05b718796861d6534b_Out_0_Vector4, (_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float.xxxx), _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4);
            float _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float, _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float);
            float4 _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4 = _MainColor;
            float4 _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float.xxxx), _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4);
            float4 _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4, _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4);
            float4 _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float.xxxx), _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4);
            float4 _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4;
            Unity_Add_float4(_Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4, _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4);
            float4 _Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4 = _FoamColor;
            float4 _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4);
            float4 _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4;
            Unity_Lerp_float4(_Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4, _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.ScreenPosition = IN.ScreenPosition;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.NDCPosition = IN.NDCPosition;
            float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d, _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float);
            float _Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float = _FoamShoreWidth;
            float _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float = _SecondFoamWidth;
            float _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float;
            Unity_Add_float(_Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float, _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float);
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dacb55c5015a42f69d937ab9d74411ae;
            float _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float, _CutOut_dacb55c5015a42f69d937ab9d74411ae, _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float);
            float _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float;
            Unity_Subtract_float(_CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float);
            float4 _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;
            float4 _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float.xxxx), _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4);
            float _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float;
            Unity_Saturate_float(_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float, _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float);
            float4 _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4, (_Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float.xxxx), _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4);
            float4 _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4, _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, float4(0, 0, 0, 0), _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4);
            float4 _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float);
            float _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float, _ProjectionParams.z, _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float);
            float4 _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3a3317424ec24fee899b24b01fe24306_R_1_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[0];
            float _Split_3a3317424ec24fee899b24b01fe24306_G_2_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[1];
            float _Split_3a3317424ec24fee899b24b01fe24306_B_3_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[2];
            float _Split_3a3317424ec24fee899b24b01fe24306_A_4_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[3];
            float _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float = _Depth;
            float _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float;
            Unity_Add_float(_Split_3a3317424ec24fee899b24b01fe24306_A_4_Float, _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float);
            float _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float;
            Unity_Subtract_float(_Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float, _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float);
            float _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float = _Strength;
            float _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float, _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float, _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float);
            float _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float;
            Unity_Clamp_float(_Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float, float(0), float(1), _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float);
            float4 _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4, (_Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float.xxxx), _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4);
            float4 _Add_8de99e76051142d0898c23e713d1946f_Out_2_Vector4;
            Unity_Add_float4(_Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4, _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Add_8de99e76051142d0898c23e713d1946f_Out_2_Vector4);
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_R_1_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[0];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_G_2_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[1];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_B_3_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[2];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[3];
            surface.BaseColor = (_Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float;
            surface.AlphaClipThreshold = float(0);
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
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
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
        float _Depth_1;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
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
        float _Depth;
        float _Strength;
        float4 _DeepWaterColor;
        float4 _MainNormal_TexelSize;
        float4 _SecondNormal_TexelSize;
        float _NormalStrength;
        float _Smoothness;
        float _Displacement;
        float _WaveSpeedFast;
        float4 _SecondFoamColor;
        float _SecondFoamWidth;
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
        TEXTURE2D(_MainNormal);
        SAMPLER(sampler_MainNormal);
        TEXTURE2D(_SecondNormal);
        SAMPLER(sampler_SecondNormal);

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

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
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

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
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
            float _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float = _Displacement;
            float3 _Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3 = float3(float(0), _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float, float(0));
            float _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float = _WaveSpeedFast;
            float _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float, _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float);
            float _Split_fe92c21c18204adebf135b67d8991a97_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_fe92c21c18204adebf135b67d8991a97_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_fe92c21c18204adebf135b67d8991a97_A_4_Float = 0;
            float _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float;
            Unity_Add_float(_Split_fe92c21c18204adebf135b67d8991a97_R_1_Float, _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float);
            float _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float;
            Unity_Add_float(_Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float, _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float);
            float _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float;
            Unity_Sine_float(_Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float, _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float);
            float3 _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3, (_Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float.xxx), _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3);
            float3 _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3, _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3);
            description.Position = _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float = _CausticsTiling;
            float _Property_ec00d672257d4fb187304144345a440d_Out_0_Float = _CausticsSpeed;
            float _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float;
            Unity_Multiply_float_float(_Property_ec00d672257d4fb187304144345a440d_Out_0_Float, IN.TimeParameters.x, _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float);
            float2 _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float.xx), (_Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float.xx), _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2);
            float4 _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.tex, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.samplerstate, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2) );
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_R_4_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.r;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_G_5_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.g;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_B_6_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.b;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_A_7_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.a;
            UnityTexture2D _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float = _CausticsTiling;
            float _Property_96f5ced09471434f906cf522badd752e_Out_0_Float = _CausticsSpeed;
            float _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float;
            Unity_Multiply_float_float(_Property_96f5ced09471434f906cf522badd752e_Out_0_Float, IN.TimeParameters.x, _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float);
            float _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float, -1, _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float);
            float2 _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float.xx), (_Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float.xx), _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2);
            float4 _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.tex, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.samplerstate, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2) );
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_R_4_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.r;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_G_5_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.g;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_B_6_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.b;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_A_7_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.a;
            float4 _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4, _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4, _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4);
            float _Property_65077cd3452749858a92d2d44870f695_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_75220f99a32f45adb650a3e5bbd83f44;
            float _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4).x, _Property_65077cd3452749858a92d2d44870f695_Out_0_Float, _CutOut_75220f99a32f45adb650a3e5bbd83f44, _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float);
            float4 _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4, (_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float.xxxx), _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_ef29a48eac0245c68a177a55dc7cc401;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.ScreenPosition = IN.ScreenPosition;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.NDCPosition = IN.NDCPosition;
            float _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_ef29a48eac0245c68a177a55dc7cc401, _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float);
            float _Property_d216d5543a364030b5a823a82377467d_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_12f43357a8eb4b5eaf77c0402280eea8;
            float _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float, _Property_d216d5543a364030b5a823a82377467d_Out_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float);
            UnityTexture2D _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float = _FoamTiling;
            float2 _Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2);
            float2 _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2, (_Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2, _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2);
            float4 _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.tex, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.samplerstate, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2) );
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_R_4_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.r;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_G_5_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.g;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_B_6_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.b;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_A_7_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.a;
            float _Property_3630b01812814cd1b91e08342a078883_Out_0_Float = _FoamDepth;
            float _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_341daa370cb0407cb1b2907742c8b230;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.ScreenPosition = IN.ScreenPosition;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.NDCPosition = IN.NDCPosition;
            float _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_3630b01812814cd1b91e08342a078883_Out_0_Float, _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float, _DepthFade_341daa370cb0407cb1b2907742c8b230, _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float);
            float4 _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4, (_DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float.xxxx), _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4);
            float _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_203a3ffd185944da95adf1d7aa062e9c;
            float _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4).x, _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float);
            float _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float;
            Unity_Add_float(_CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float, _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float);
            float _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float;
            Unity_Saturate_float(_Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float, _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float);
            float _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float;
            Unity_OneMinus_float(_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float, _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float);
            float _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float;
            Unity_OneMinus_float(_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float);
            float _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float;
            Unity_Add_float(_OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float, _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float);
            float4 _Property_b323242895734c05b718796861d6534b_Out_0_Vector4 = _ShoreColor;
            float _Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float = _Depth;
            float _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.ScreenPosition = IN.ScreenPosition;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.NDCPosition = IN.NDCPosition;
            float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float, _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float);
            float4 _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_b323242895734c05b718796861d6534b_Out_0_Vector4, (_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float.xxxx), _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4);
            float _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float, _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float);
            float4 _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4 = _MainColor;
            float4 _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float.xxxx), _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4);
            float4 _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4, _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4);
            float4 _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float.xxxx), _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4);
            float4 _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4;
            Unity_Add_float4(_Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4, _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4);
            float4 _Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4 = _FoamColor;
            float4 _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4);
            float4 _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4;
            Unity_Lerp_float4(_Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4, _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.ScreenPosition = IN.ScreenPosition;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.NDCPosition = IN.NDCPosition;
            float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d, _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float);
            float _Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float = _FoamShoreWidth;
            float _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float = _SecondFoamWidth;
            float _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float;
            Unity_Add_float(_Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float, _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float);
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dacb55c5015a42f69d937ab9d74411ae;
            float _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float, _CutOut_dacb55c5015a42f69d937ab9d74411ae, _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float);
            float _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float;
            Unity_Subtract_float(_CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float);
            float4 _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;
            float4 _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float.xxxx), _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4);
            float _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float;
            Unity_Saturate_float(_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float, _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float);
            float4 _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4, (_Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float.xxxx), _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4);
            float4 _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4, _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, float4(0, 0, 0, 0), _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4);
            float4 _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float);
            float _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float, _ProjectionParams.z, _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float);
            float4 _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3a3317424ec24fee899b24b01fe24306_R_1_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[0];
            float _Split_3a3317424ec24fee899b24b01fe24306_G_2_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[1];
            float _Split_3a3317424ec24fee899b24b01fe24306_B_3_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[2];
            float _Split_3a3317424ec24fee899b24b01fe24306_A_4_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[3];
            float _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float = _Depth;
            float _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float;
            Unity_Add_float(_Split_3a3317424ec24fee899b24b01fe24306_A_4_Float, _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float);
            float _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float;
            Unity_Subtract_float(_Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float, _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float);
            float _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float = _Strength;
            float _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float, _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float, _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float);
            float _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float;
            Unity_Clamp_float(_Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float, float(0), float(1), _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float);
            float4 _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4, (_Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float.xxxx), _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4);
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_R_1_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[0];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_G_2_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[1];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_B_3_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[2];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[3];
            surface.Alpha = _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float;
            surface.AlphaClipThreshold = float(0);
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
        #define _ALPHATEST_ON 1
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
        float _Depth_1;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
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
        float _Depth;
        float _Strength;
        float4 _DeepWaterColor;
        float4 _MainNormal_TexelSize;
        float4 _SecondNormal_TexelSize;
        float _NormalStrength;
        float _Smoothness;
        float _Displacement;
        float _WaveSpeedFast;
        float4 _SecondFoamColor;
        float _SecondFoamWidth;
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
        TEXTURE2D(_MainNormal);
        SAMPLER(sampler_MainNormal);
        TEXTURE2D(_SecondNormal);
        SAMPLER(sampler_SecondNormal);

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

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
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

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
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
            float _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float = _Displacement;
            float3 _Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3 = float3(float(0), _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float, float(0));
            float _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float = _WaveSpeedFast;
            float _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float, _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float);
            float _Split_fe92c21c18204adebf135b67d8991a97_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_fe92c21c18204adebf135b67d8991a97_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_fe92c21c18204adebf135b67d8991a97_A_4_Float = 0;
            float _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float;
            Unity_Add_float(_Split_fe92c21c18204adebf135b67d8991a97_R_1_Float, _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float);
            float _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float;
            Unity_Add_float(_Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float, _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float);
            float _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float;
            Unity_Sine_float(_Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float, _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float);
            float3 _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3, (_Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float.xxx), _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3);
            float3 _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3, _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3);
            description.Position = _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float = _CausticsTiling;
            float _Property_ec00d672257d4fb187304144345a440d_Out_0_Float = _CausticsSpeed;
            float _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float;
            Unity_Multiply_float_float(_Property_ec00d672257d4fb187304144345a440d_Out_0_Float, IN.TimeParameters.x, _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float);
            float2 _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float.xx), (_Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float.xx), _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2);
            float4 _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.tex, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.samplerstate, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2) );
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_R_4_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.r;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_G_5_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.g;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_B_6_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.b;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_A_7_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.a;
            UnityTexture2D _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float = _CausticsTiling;
            float _Property_96f5ced09471434f906cf522badd752e_Out_0_Float = _CausticsSpeed;
            float _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float;
            Unity_Multiply_float_float(_Property_96f5ced09471434f906cf522badd752e_Out_0_Float, IN.TimeParameters.x, _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float);
            float _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float, -1, _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float);
            float2 _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float.xx), (_Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float.xx), _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2);
            float4 _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.tex, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.samplerstate, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2) );
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_R_4_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.r;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_G_5_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.g;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_B_6_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.b;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_A_7_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.a;
            float4 _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4, _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4, _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4);
            float _Property_65077cd3452749858a92d2d44870f695_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_75220f99a32f45adb650a3e5bbd83f44;
            float _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4).x, _Property_65077cd3452749858a92d2d44870f695_Out_0_Float, _CutOut_75220f99a32f45adb650a3e5bbd83f44, _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float);
            float4 _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4, (_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float.xxxx), _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_ef29a48eac0245c68a177a55dc7cc401;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.ScreenPosition = IN.ScreenPosition;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.NDCPosition = IN.NDCPosition;
            float _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_ef29a48eac0245c68a177a55dc7cc401, _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float);
            float _Property_d216d5543a364030b5a823a82377467d_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_12f43357a8eb4b5eaf77c0402280eea8;
            float _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float, _Property_d216d5543a364030b5a823a82377467d_Out_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float);
            UnityTexture2D _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float = _FoamTiling;
            float2 _Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2);
            float2 _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2, (_Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2, _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2);
            float4 _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.tex, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.samplerstate, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2) );
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_R_4_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.r;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_G_5_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.g;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_B_6_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.b;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_A_7_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.a;
            float _Property_3630b01812814cd1b91e08342a078883_Out_0_Float = _FoamDepth;
            float _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_341daa370cb0407cb1b2907742c8b230;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.ScreenPosition = IN.ScreenPosition;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.NDCPosition = IN.NDCPosition;
            float _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_3630b01812814cd1b91e08342a078883_Out_0_Float, _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float, _DepthFade_341daa370cb0407cb1b2907742c8b230, _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float);
            float4 _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4, (_DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float.xxxx), _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4);
            float _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_203a3ffd185944da95adf1d7aa062e9c;
            float _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4).x, _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float);
            float _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float;
            Unity_Add_float(_CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float, _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float);
            float _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float;
            Unity_Saturate_float(_Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float, _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float);
            float _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float;
            Unity_OneMinus_float(_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float, _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float);
            float _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float;
            Unity_OneMinus_float(_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float);
            float _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float;
            Unity_Add_float(_OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float, _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float);
            float4 _Property_b323242895734c05b718796861d6534b_Out_0_Vector4 = _ShoreColor;
            float _Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float = _Depth;
            float _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.ScreenPosition = IN.ScreenPosition;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.NDCPosition = IN.NDCPosition;
            float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float, _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float);
            float4 _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_b323242895734c05b718796861d6534b_Out_0_Vector4, (_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float.xxxx), _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4);
            float _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float, _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float);
            float4 _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4 = _MainColor;
            float4 _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float.xxxx), _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4);
            float4 _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4, _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4);
            float4 _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float.xxxx), _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4);
            float4 _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4;
            Unity_Add_float4(_Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4, _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4);
            float4 _Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4 = _FoamColor;
            float4 _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4);
            float4 _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4;
            Unity_Lerp_float4(_Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4, _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.ScreenPosition = IN.ScreenPosition;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.NDCPosition = IN.NDCPosition;
            float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d, _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float);
            float _Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float = _FoamShoreWidth;
            float _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float = _SecondFoamWidth;
            float _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float;
            Unity_Add_float(_Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float, _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float);
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dacb55c5015a42f69d937ab9d74411ae;
            float _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float, _CutOut_dacb55c5015a42f69d937ab9d74411ae, _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float);
            float _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float;
            Unity_Subtract_float(_CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float);
            float4 _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;
            float4 _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float.xxxx), _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4);
            float _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float;
            Unity_Saturate_float(_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float, _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float);
            float4 _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4, (_Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float.xxxx), _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4);
            float4 _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4, _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, float4(0, 0, 0, 0), _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4);
            float4 _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float);
            float _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float, _ProjectionParams.z, _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float);
            float4 _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3a3317424ec24fee899b24b01fe24306_R_1_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[0];
            float _Split_3a3317424ec24fee899b24b01fe24306_G_2_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[1];
            float _Split_3a3317424ec24fee899b24b01fe24306_B_3_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[2];
            float _Split_3a3317424ec24fee899b24b01fe24306_A_4_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[3];
            float _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float = _Depth;
            float _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float;
            Unity_Add_float(_Split_3a3317424ec24fee899b24b01fe24306_A_4_Float, _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float);
            float _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float;
            Unity_Subtract_float(_Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float, _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float);
            float _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float = _Strength;
            float _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float, _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float, _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float);
            float _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float;
            Unity_Clamp_float(_Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float, float(0), float(1), _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float);
            float4 _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4, (_Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float.xxxx), _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4);
            float4 _Add_8de99e76051142d0898c23e713d1946f_Out_2_Vector4;
            Unity_Add_float4(_Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4, _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Add_8de99e76051142d0898c23e713d1946f_Out_2_Vector4);
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_R_1_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[0];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_G_2_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[1];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_B_3_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[2];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[3];
            surface.BaseColor = (_Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4.xyz);
            surface.Alpha = _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float;
            surface.AlphaClipThreshold = float(0);
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
        #define _ALPHATEST_ON 1
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
        float _Depth_1;
        float _DepthFallOff;
        float4 _MainColor;
        float4 _ShoreColor;
        float _FoamShoreWidth;
        float4 _FoamColor;
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
        float _Depth;
        float _Strength;
        float4 _DeepWaterColor;
        float4 _MainNormal_TexelSize;
        float4 _SecondNormal_TexelSize;
        float _NormalStrength;
        float _Smoothness;
        float _Displacement;
        float _WaveSpeedFast;
        float4 _SecondFoamColor;
        float _SecondFoamWidth;
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
        TEXTURE2D(_MainNormal);
        SAMPLER(sampler_MainNormal);
        TEXTURE2D(_SecondNormal);
        SAMPLER(sampler_SecondNormal);

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

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
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

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
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

        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
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
            float _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float = _Displacement;
            float3 _Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3 = float3(float(0), _Property_daae0e762e704e3da8a1e03ee7ad3dbf_Out_0_Float, float(0));
            float _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float = _WaveSpeedFast;
            float _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_ac6477514efd41ffba290127d014c5ea_Out_0_Float, _Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float);
            float _Split_fe92c21c18204adebf135b67d8991a97_R_1_Float = IN.WorldSpacePosition[0];
            float _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float = IN.WorldSpacePosition[1];
            float _Split_fe92c21c18204adebf135b67d8991a97_B_3_Float = IN.WorldSpacePosition[2];
            float _Split_fe92c21c18204adebf135b67d8991a97_A_4_Float = 0;
            float _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float;
            Unity_Add_float(_Split_fe92c21c18204adebf135b67d8991a97_R_1_Float, _Split_fe92c21c18204adebf135b67d8991a97_G_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float);
            float _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float;
            Unity_Add_float(_Multiply_7252fb103c7d489cb24e49b091275fd9_Out_2_Float, _Add_9b3659b561c84e4383c2cef92f55d536_Out_2_Float, _Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float);
            float _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float;
            Unity_Sine_float(_Add_9c84e4fcd1744f1f86e8b102c458bf0a_Out_2_Float, _Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float);
            float3 _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Vector3_d9ce40ceaf0941a7aa05f4ed9de9d2a2_Out_0_Vector3, (_Sine_d929c6df8f9f4fc5abd2ef2e1dc8752d_Out_1_Float.xxx), _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3);
            float3 _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6370799a7dec4509b5398919a6c0b549_Out_2_Vector3, _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3);
            description.Position = _Add_47fbb0bf869348d6b0d5554c613152b2_Out_2_Vector3;
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
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_CausticColor) : _CausticColor;
            UnityTexture2D _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float = _CausticsTiling;
            float _Property_ec00d672257d4fb187304144345a440d_Out_0_Float = _CausticsSpeed;
            float _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float;
            Unity_Multiply_float_float(_Property_ec00d672257d4fb187304144345a440d_Out_0_Float, IN.TimeParameters.x, _Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float);
            float2 _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_d80921190a3044e3bce55a660f7fe32e_Out_0_Float.xx), (_Multiply_174fc0896ba748999a27a18ec6ac4a87_Out_2_Float.xx), _TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2);
            float4 _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.tex, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.samplerstate, _Property_7ac241bc378d401b9d33ceccde05d80c_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_8b77aed9f2434ab8b1392b38ce281095_Out_3_Vector2) );
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_R_4_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.r;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_G_5_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.g;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_B_6_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.b;
            float _SampleTexture2D_692d3340754f4d408a5859a8345e8477_A_7_Float = _SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4.a;
            UnityTexture2D _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CausticTexture);
            float _Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float = _CausticsTiling;
            float _Property_96f5ced09471434f906cf522badd752e_Out_0_Float = _CausticsSpeed;
            float _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float;
            Unity_Multiply_float_float(_Property_96f5ced09471434f906cf522badd752e_Out_0_Float, IN.TimeParameters.x, _Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float);
            float _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_f7ff1d22a3af49d1958122ee8e9f7617_Out_2_Float, -1, _Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float);
            float2 _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_44bf246d919a4ecdb35b87f0ca010b64_Out_0_Float.xx), (_Multiply_29c84c73d67d4aa786e12c923823f9d5_Out_2_Float.xx), _TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2);
            float4 _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.tex, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.samplerstate, _Property_fd08d864e73345a2a2477d0677b685ec_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_75f1613c5f0e47cbbe05364ab160afb5_Out_3_Vector2) );
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_R_4_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.r;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_G_5_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.g;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_B_6_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.b;
            float _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_A_7_Float = _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4.a;
            float4 _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_692d3340754f4d408a5859a8345e8477_RGBA_0_Vector4, _SampleTexture2D_be8d2c4e877e4238bf07b273e6f3bdc2_RGBA_0_Vector4, _Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4);
            float _Property_65077cd3452749858a92d2d44870f695_Out_0_Float = _CausticCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_75220f99a32f45adb650a3e5bbd83f44;
            float _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_7713f9a450d24e62839338b35efcdb2f_Out_2_Vector4).x, _Property_65077cd3452749858a92d2d44870f695_Out_0_Float, _CutOut_75220f99a32f45adb650a3e5bbd83f44, _CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float);
            float4 _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_1ed0744091fc4c19a3c129a48cc969eb_Out_0_Vector4, (_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float.xxxx), _Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_ef29a48eac0245c68a177a55dc7cc401;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.ScreenPosition = IN.ScreenPosition;
            _DepthFade_ef29a48eac0245c68a177a55dc7cc401.NDCPosition = IN.NDCPosition;
            float _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_ef29a48eac0245c68a177a55dc7cc401, _DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float);
            float _Property_d216d5543a364030b5a823a82377467d_Out_0_Float = _FoamShoreWidth;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_12f43357a8eb4b5eaf77c0402280eea8;
            float _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_ef29a48eac0245c68a177a55dc7cc401_OutVector1_1_Float, _Property_d216d5543a364030b5a823a82377467d_Out_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float);
            UnityTexture2D _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_FoamTexture);
            float2 _Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2 = IN.WorldSpacePosition.xz;
            float _Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float = _FoamTiling;
            float2 _Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2 = _FoamSpeed;
            float2 _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_bdccdcc7f3aa46bfb5cbb7425d0811d6_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2);
            float2 _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2;
            Unity_TilingAndOffset_float(_Swizzle_5a020c22959e492ba9c97644a2a1505c_Out_1_Vector2, (_Property_f4873119e7b944e08b219e45b8533a31_Out_0_Float.xx), _Multiply_4dd86396a03c4f48af20dc53a12d09a2_Out_2_Vector2, _TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2);
            float4 _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.tex, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.samplerstate, _Property_ec7dcfe5fa07424cb89968c43aac613b_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b3c8802fdaa04f3f9a4166c623bd0953_Out_3_Vector2) );
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_R_4_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.r;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_G_5_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.g;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_B_6_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.b;
            float _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_A_7_Float = _SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4.a;
            float _Property_3630b01812814cd1b91e08342a078883_Out_0_Float = _FoamDepth;
            float _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float = _FoamFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_341daa370cb0407cb1b2907742c8b230;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.ScreenPosition = IN.ScreenPosition;
            _DepthFade_341daa370cb0407cb1b2907742c8b230.NDCPosition = IN.NDCPosition;
            float _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_3630b01812814cd1b91e08342a078883_Out_0_Float, _Property_3a672a281f2c4ef7883e78e4c4c24469_Out_0_Float, _DepthFade_341daa370cb0407cb1b2907742c8b230, _DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float);
            float4 _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_9aded2117dbf40b9bca63b1a2672fbfc_RGBA_0_Vector4, (_DepthFade_341daa370cb0407cb1b2907742c8b230_OutVector1_1_Float.xxxx), _Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4);
            float _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float = _FoamCutOut;
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_203a3ffd185944da95adf1d7aa062e9c;
            float _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float((_Multiply_0317e1a392b148af83bdfba21282d2d5_Out_2_Vector4).x, _Property_69f3ae79700e41c9a71edd9b4c73aa53_Out_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float);
            float _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float;
            Unity_Add_float(_CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _CutOut_203a3ffd185944da95adf1d7aa062e9c_Output_0_Float, _Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float);
            float _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float;
            Unity_Saturate_float(_Add_752dcbb48a554a84b36c159b1a8478b1_Out_2_Float, _Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float);
            float _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float;
            Unity_OneMinus_float(_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float, _OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float);
            float _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float;
            Unity_OneMinus_float(_CutOut_75220f99a32f45adb650a3e5bbd83f44_Output_0_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float);
            float _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float;
            Unity_Add_float(_OneMinus_f7f3ba36db83482eb26607a8f43c9df5_Out_1_Float, _OneMinus_886ecb3ba18e4f288a6a71e0492d79f6_Out_1_Float, _Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float);
            float4 _Property_b323242895734c05b718796861d6534b_Out_0_Vector4 = _ShoreColor;
            float _Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float = _Depth;
            float _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float = _DepthFallOff;
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.ScreenPosition = IN.ScreenPosition;
            _DepthFade_35462eb1c2574f01841efcbf81ba3fc2.NDCPosition = IN.NDCPosition;
            float _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(_Property_d18a632bed0c4b588fec52b880feb84d_Out_0_Float, _Property_5fa275c755c645f881dd7d1862a97a33_Out_0_Float, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2, _DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float);
            float4 _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_b323242895734c05b718796861d6534b_Out_0_Vector4, (_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float.xxxx), _Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4);
            float _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float;
            Unity_OneMinus_float(_DepthFade_35462eb1c2574f01841efcbf81ba3fc2_OutVector1_1_Float, _OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float);
            float4 _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4 = _MainColor;
            float4 _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_OneMinus_0ebbfb59b60c40cf88d285ed6cdc1bae_Out_1_Float.xxxx), _Property_5521772919244de6b3470c68cce868cb_Out_0_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4);
            float4 _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4;
            Unity_Add_float4(_Multiply_a9790a7fdb3f418f963378d80011534f_Out_2_Vector4, _Multiply_805d4a54e5524af6bbc8e5a60390159a_Out_2_Vector4, _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4);
            float4 _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Add_3b6f9ba26f7b4cbbbfa4090fdc8f3833_Out_2_Float.xxxx), _Add_016b8ac4f4594f44aaddf87c7ff00a65_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4);
            float4 _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4;
            Unity_Add_float4(_Multiply_206764700fe947df979877438d3780a7_Out_2_Vector4, _Multiply_feca2eaac4c148858c73040cbd2e755a_Out_2_Vector4, _Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4);
            float4 _Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4 = _FoamColor;
            float4 _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_4ec0c5730e164c3dac2e7326973a7cf1_Out_0_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4);
            float4 _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4;
            Unity_Lerp_float4(_Add_651443a802bc4681bb8bce7a3e6e1a56_Out_2_Vector4, _Multiply_fd1d927099664aaeb0028871a4927894_Out_2_Vector4, (_Saturate_9fa534a7c72a467d8d6c9fb3d963bade_Out_1_Float.xxxx), _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4);
            Bindings_DepthFade_fd37366848b771042941ee5121343adf_float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.ScreenPosition = IN.ScreenPosition;
            _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d.NDCPosition = IN.NDCPosition;
            float _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float;
            SG_DepthFade_fd37366848b771042941ee5121343adf_float(float(1), float(1), _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d, _DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float);
            float _Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float = _FoamShoreWidth;
            float _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float = _SecondFoamWidth;
            float _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float;
            Unity_Add_float(_Property_05ecbe1a3be241f0a5d0813546b6ef4f_Out_0_Float, _Property_8bf8c56db6744776be2bef73bfd1f877_Out_0_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float);
            Bindings_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float _CutOut_dacb55c5015a42f69d937ab9d74411ae;
            float _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float;
            SG_CutOut_f8fc631f1e5116b4c9d1a763235a9b23_float(_DepthFade_a1fc8a913c044b81a8b55ec02db14b8d_OutVector1_1_Float, _Add_3ff16cea0ca542ca9931dad32d75583f_Out_2_Float, _CutOut_dacb55c5015a42f69d937ab9d74411ae, _CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float);
            float _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float;
            Unity_Subtract_float(_CutOut_dacb55c5015a42f69d937ab9d74411ae_Output_0_Float, _CutOut_12f43357a8eb4b5eaf77c0402280eea8_Output_0_Float, _Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float);
            float4 _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_SecondFoamColor) : _SecondFoamColor;
            float4 _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float.xxxx), _Property_c8b694ebd96649268653bd60fa70557b_Out_0_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4);
            float _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float;
            Unity_Saturate_float(_Subtract_125a457d746a43d3a32bf11e2d2a4c0e_Out_2_Float, _Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float);
            float4 _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, _Multiply_7b6e555e8ecd48e8905822ab9de23bdf_Out_2_Vector4, (_Saturate_f15b5aaafd6243728b41f6e4b4b7c03f_Out_1_Float.xxxx), _Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4);
            float4 _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_21465a620e484873ae018d1f6f3ac656_Out_3_Vector4, _Lerp_0c089b7d300847d0ad925818eae52cf4_Out_3_Vector4, float4(0, 0, 0, 0), _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4);
            float4 _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4 = _DeepWaterColor;
            float _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float;
            Unity_SceneDepth_Linear01_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float);
            float _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float;
            Unity_Multiply_float_float(_SceneDepth_e0ce0cb90b6f46109d648b3783bdf842_Out_1_Float, _ProjectionParams.z, _Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float);
            float4 _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4 = IN.ScreenPosition;
            float _Split_3a3317424ec24fee899b24b01fe24306_R_1_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[0];
            float _Split_3a3317424ec24fee899b24b01fe24306_G_2_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[1];
            float _Split_3a3317424ec24fee899b24b01fe24306_B_3_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[2];
            float _Split_3a3317424ec24fee899b24b01fe24306_A_4_Float = _ScreenPosition_09d9100a4fd34b22b999c8d84647c9c4_Out_0_Vector4[3];
            float _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float = _Depth;
            float _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float;
            Unity_Add_float(_Split_3a3317424ec24fee899b24b01fe24306_A_4_Float, _Property_2daab65ed4f84344a6e1a50d744aa443_Out_0_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float);
            float _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float;
            Unity_Subtract_float(_Multiply_0279fb3ab1b84ff9bac7ec4974b748ed_Out_2_Float, _Add_9193b2dcc0c64297af00bde05133543a_Out_2_Float, _Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float);
            float _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float = _Strength;
            float _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_79249a67169b45289f00d86ccf16edd1_Out_2_Float, _Property_cda2e0c2a50c4c33bfac4ab28f08c728_Out_0_Float, _Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float);
            float _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float;
            Unity_Clamp_float(_Multiply_71fe20d6834f45d894902ffc8d067d2c_Out_2_Float, float(0), float(1), _Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float);
            float4 _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4;
            Unity_Lerp_float4(_Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Property_1168177bbc4d4b00b8a66dc6547b5494_Out_0_Vector4, (_Clamp_eb6befc0037d45e88271d9aab26815f1_Out_3_Float.xxxx), _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4);
            float4 _Add_8de99e76051142d0898c23e713d1946f_Out_2_Vector4;
            Unity_Add_float4(_Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4, _Lerp_2b1e144ca86c45dd94c53d2235a93705_Out_3_Vector4, _Add_8de99e76051142d0898c23e713d1946f_Out_2_Vector4);
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_R_1_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[0];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_G_2_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[1];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_B_3_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[2];
            float _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float = _Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4[3];
            surface.BaseColor = (_Lerp_8ece8d931a474f71be530186de492186_Out_3_Vector4.xyz);
            surface.Alpha = _Split_cc73a35e6dd24b53af42c2ade00d3554_A_4_Float;
            surface.AlphaClipThreshold = float(0);
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