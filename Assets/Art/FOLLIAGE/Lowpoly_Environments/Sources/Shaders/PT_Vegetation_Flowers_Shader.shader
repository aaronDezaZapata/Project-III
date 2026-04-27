Shader "Polytope Studio/PT_Vegetation_Flowers_Shader"
{
    Properties
    {
        [NoScaleOffset]_BASETEXTURE("BASE TEXTURE", 2D) = "white" {}

        [Toggle]_CUSTOMCOLORSTINTING("CUSTOM COLORS TINTING", Float) = 1
        _TopColor("Top Color", Color) = (0.3505436,0.5754717,0.3338822,1)
        _GroundColor("Ground Color", Color) = (0.1879673,0.3113208,0.1776878,1)
        _Gradient("Gradient", Range(0,1)) = 1
        _GradientPower1("Gradient Power", Range(0,10)) = 1

        _LeavesThickness("Leaves Thickness", Range(0.1,0.95)) = 0.5

        [Toggle]_CUSTOMFLOWERSCOLOR("CUSTOM FLOWERS COLOR", Float) = 0
        [HideInInspector]_MaskClipValue("Mask Clip Value", Range(0,1)) = 0.5
        [HDR]_FLOWERSCOLOR("FLOWERS COLOR", Color) = (1,0,0,1)

        [Toggle]_CUSTOMWIND("CUSTOM WIND", Float) = 1
        _WindMovement("Wind Movement", Range(0,1)) = 0.5
        _WindDensity("Wind Density", Range(0,5)) = 0.2
        _WindStrength("Wind Strength", Range(0,1)) = 0.3
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest"
        }

        Cull Off
        ZWrite On
        ZTest LEqual

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BASETEXTURE);
            SAMPLER(sampler_BASETEXTURE);

            CBUFFER_START(UnityPerMaterial)
                float4 _BASETEXTURE_ST;

                float _CUSTOMCOLORSTINTING;
                float4 _TopColor;
                float4 _GroundColor;
                float _Gradient;
                float _GradientPower1;

                float _LeavesThickness;
                float _CUSTOMFLOWERSCOLOR;
                float _MaskClipValue;
                float4 _FLOWERSCOLOR;

                float _CUSTOMWIND;
                float _WindMovement;
                float _WindDensity;
                float _WindStrength;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionOS : TEXCOORD1;
                float fogCoord : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            float hash21(float2 p)
            {
                p = frac(p * float2(123.34, 345.45));
                p += dot(p, p + 34.345);
                return frac(p.x * p.y);
            }

            float noise2D(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float a = hash21(i);
                float b = hash21(i + float2(1.0, 0.0));
                float c = hash21(i + float2(0.0, 1.0));
                float d = hash21(i + float2(1.0, 1.0));

                float2 u = f * f * (3.0 - 2.0 * f);

                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                float3 posOS = IN.positionOS.xyz;

                float windNoise = noise2D((posOS.xy + _Time.y * _WindMovement) * _WindDensity);
                float windOffset = ((windNoise - 0.5) / 10.0) * _WindStrength;

                float heightMask = saturate(posOS.y * 2.0);

                posOS.x += windOffset * heightMask * _CUSTOMWIND;

                OUT.positionOS = posOS;
                OUT.uv = IN.uv;
                OUT.positionCS = TransformObjectToHClip(posOS);
                OUT.fogCoord = ComputeFogFactor(OUT.positionCS.z);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);

                half4 tex = SAMPLE_TEXTURE2D(_BASETEXTURE, sampler_BASETEXTURE, IN.uv);

                float alphaMask = 1.0 - step(tex.a, 1.0 - _LeavesThickness);
                clip(alphaMask - _MaskClipValue);

                float grayscale = dot(tex.rgb, float3(0.299, 0.587, 0.114));

                float gradientMask = saturate(pow(saturate(IN.positionOS.y * 1.5 + 0.5) * _Gradient, _GradientPower1));
                half3 gradientColor = lerp(_GroundColor.rgb, _TopColor.rgb, gradientMask);

                half3 baseColor = tex.rgb;

                half3 tintedLeaves = grayscale * gradientColor;

                // Detecta la zona de la flor en la textura.
                // En este asset la flor está en la parte superior derecha del atlas.
                float flowerMask = step(0.5, IN.uv.x) * step(0.5, IN.uv.y);

                // Color de hojas con gradiente
                half3 leafColor = grayscale * gradientColor;

                // Color de flor.
                // Si CUSTOM FLOWERS COLOR está activado, usa FLOWERS COLOR.
                // Si está desactivado, mantiene el color original de la textura.
                half3 flowerColor = lerp(tex.rgb, grayscale * _FLOWERSCOLOR.rgb, _CUSTOMFLOWERSCOLOR);

                // Primero separamos hojas y flores.
                // Las hojas usan Top/Ground Color.
                // Las flores usan Flower Color.
                half3 tintedColor = lerp(leafColor, flowerColor, flowerMask);

                // Si CUSTOM COLORS TINTING está apagado, usa la textura original.
                // Si está encendido, usa el sistema de colores.
                half3 finalColor = lerp(tex.rgb, tintedColor, _CUSTOMCOLORSTINTING);

                return half4(finalColor, 1.0);
            }

            ENDHLSL
        }
    }

    Fallback Off
}