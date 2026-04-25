Shader "Polytope Studio/PT_Vegetation_Foliage_Shader"
{
    Properties
    {
        [NoScaleOffset]_BaseTexture("Base Texture", 2D) = "white" {}

        [Toggle]_CUSTOMCOLORSTINTING("CUSTOM COLORS  TINTING", Float) = 0
        [HDR]_TopColor("Top Color", Color) = (0,0.2178235,1,1)
        [HDR]_GroundColor("Ground Color", Color) = (1,0,0,1)
        [HDR]_Gradient("Gradient", Range(0,1)) = 1
        _GradientPower("Gradient Power", Range(0,10)) = 5

        _LeavesThickness("Leaves Thickness", Range(0.1,0.95)) = 0.5
        _Smoothness("Smoothness", Range(0,1)) = 0

        [Toggle]_TRANSLUCENCYONOFF("TRANSLUCENCY ON/OFF", Float) = 1
        [Header(Translucency)]
        _Translucency("Strength", Range(0,50)) = 1
        _TransNormalDistortion("Normal Distortion", Range(0,1)) = 0.1
        _TransScattering("Scaterring Falloff", Range(1,50)) = 2
        _TransDirect("Direct", Range(0,1)) = 1
        _TransAmbient("Ambient", Range(0,1)) = 0.2
        _TransShadow("Shadow", Range(0,1)) = 0.9

        [HideInInspector]_MaskClipValue("Mask Clip Value", Range(0,1)) = 0.5

        [Toggle]_CUSTOMWIND("CUSTOM WIND", Float) = 1
        [Toggle]_WINDMASKONOFF("WIND MASK ON/OFF", Float) = 0
        _WindMovement("Wind Movement", Range(0,10)) = 0.5
        _WindDensity("Wind Density", Range(0,5)) = 3.3
        _WindStrength("Wind Strength", Range(0,1)) = 0.3

        [Toggle]_SNOWONOFF("SNOW ON/OFF", Float) = 0
        _SnowGradient("Snow Gradient", Range(0,1)) = 0.83
        _SnowCoverage("Snow Coverage", Range(0,1)) = 0.45
        _SnowAmount("Snow Amount", Range(0,1)) = 1
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
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_BaseTexture);
            SAMPLER(sampler_BaseTexture);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseTexture_ST;

                float _CUSTOMCOLORSTINTING;
                float4 _TopColor;
                float4 _GroundColor;
                float _Gradient;
                float _GradientPower;

                float _LeavesThickness;
                float _Smoothness;

                float _TRANSLUCENCYONOFF;
                float _Translucency;
                float _TransNormalDistortion;
                float _TransScattering;
                float _TransDirect;
                float _TransAmbient;
                float _TransShadow;

                float _MaskClipValue;

                float _CUSTOMWIND;
                float _WINDMASKONOFF;
                float _WindMovement;
                float _WindDensity;
                float _WindStrength;

                float _SNOWONOFF;
                float _SnowGradient;
                float _SnowCoverage;
                float _SnowAmount;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 positionOS : TEXCOORD3;
                float fogCoord : TEXCOORD4;
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

                float3 posOS = IN.positionOS.xyz;

                float windNoise = noise2D((posOS.xy + _Time.y * _WindMovement) * _WindDensity);
                float windOffset = ((windNoise - 0.5) / 10.0) * _WindStrength;

                float heightMaskByVertex = saturate(posOS.y);
                float heightMaskByUV = saturate((1.0 - IN.uv.y) * 5.0);

                float finalWindMask = lerp(heightMaskByVertex, heightMaskByUV, _WINDMASKONOFF);

                posOS.x += windOffset * finalWindMask * _CUSTOMWIND;

                OUT.positionOS = posOS;
                OUT.uv = IN.uv;
                OUT.positionWS = TransformObjectToWorld(posOS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionCS = TransformWorldToHClip(OUT.positionWS);
                OUT.fogCoord = ComputeFogFactor(OUT.positionCS.z);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 tex = SAMPLE_TEXTURE2D(_BaseTexture, sampler_BaseTexture, IN.uv);

                float alphaCut = 1.0 - step(tex.a, 1.0 - _LeavesThickness);
                clip(alphaCut - _MaskClipValue);

                float grayscale = dot(tex.rgb, float3(0.299, 0.587, 0.114));

                float gradientMask = saturate(
                    pow(
                        saturate((0.5 + IN.positionOS.y * 1.5) * _Gradient),
                        _GradientPower
                    )
                );

                half3 gradientColor = lerp(_GroundColor.rgb, _TopColor.rgb, gradientMask);

                half3 tintedColor = saturate(grayscale * gradientColor);

                half3 baseColor = lerp(tex.rgb, tintedColor, _CUSTOMCOLORSTINTING);

                float3 normalWS = normalize(IN.normalWS);
                float3 viewDirWS = normalize(GetWorldSpaceViewDir(IN.positionWS));

                Light mainLight = GetMainLight();
                float NdotL = saturate(dot(normalWS, mainLight.direction));

                half3 lightColor = mainLight.color * (NdotL * 0.75 + 0.25);

                float fresnel = pow(1.0 - saturate(dot(normalWS, viewDirWS)), _TransScattering);
                half3 translucency = baseColor * fresnel * _Translucency * 0.05 * _TRANSLUCENCYONOFF;

                half3 finalColor = baseColor * lightColor + translucency;

                float snowVerticalMask = smoothstep(
                    0.0,
                    max(_SnowGradient, 0.001),
                    (IN.uv.y * 0.65) + lerp(-1.0, 1.0, _SnowCoverage)
                );

                float snowFresnel = pow(1.0 - saturate(dot(normalWS, viewDirWS)), 1.0);
                float snowMask = snowVerticalMask * snowFresnel * _SnowAmount * _SNOWONOFF;

                finalColor = lerp(finalColor, half3(1.0, 1.0, 1.0), saturate(snowMask));

                finalColor = MixFog(finalColor, IN.fogCoord);

                return half4(finalColor, 1.0);
            }

            ENDHLSL
        }
    }

    Fallback Off
}