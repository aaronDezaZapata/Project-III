Shader "Polytope Studio/PT_Rock_Shader"
{
    Properties
    {
        [NoScaleOffset]_BaseTexture("Base Texture", 2D) = "white" {}
        _Smoothness("Smoothness", Range(0,1)) = 0.2

        [Toggle]_GRADIENTONOFF("GRADIENT  ON/OFF", Float) = 0
        [HDR]_TopColor("Top Color", Color) = (0.4811321,0.4036026,0.2382966,1)
        [HDR]_GroundColor("Ground Color", Color) = (0.08490568,0.05234205,0.04846032,1)
        [HideInInspector]_SnowDirection("Snow Direction", Vector) = (0.1,1,0.1,0)
        _Gradient("Gradient ", Range(0,1)) = 1
        _GradientPower("Gradient Power", Range(0,10)) = 1
        [Toggle]_WorldObjectGradient("World/Object Gradient", Float) = 1

        [Toggle]_DECALSONOFF("DECALS ON/OFF", Float) = 0
        [NoScaleOffset]_DecalsTexture("Decals Texture", 2D) = "white" {}
        _DecalsColor("Decals Color", Color) = (0,0,0,0)

        [Toggle]_DECALEMISSIONONOFF("DECAL EMISSION ON/OFF", Float) = 1
        [HDR]_DecakEmissionColor("Decak Emission Color", Color) = (1,0.9248579,0,0)
        _DecalEmissionIntensity("Decal Emission Intensity", Range(0,10)) = 4
        [Toggle]_ANIMATEDECALEMISSIONONOFF("ANIMATE DECAL EMISSION ON/OFF", Float) = 1

        [Toggle]_DETAILTEXTUREONOFF("DETAIL TEXTURE  ON/OFF", Float) = 0
        [NoScaleOffset]_DetailTexture("Detail Texture", 2D) = "white" {}
        _DetailTextureTiling("Detail Texture Tiling", Range(0.1,10)) = 0.5

        [Toggle]_SNOWONOFF("SNOW ON/OFF", Float) = 0
        _SnowCoverage("Snow Coverage", Range(0,1)) = 0.46
        _SnowAmount("Snow Amount", Range(0,1)) = 1
        _SnowFade("Snow Fade", Range(0,1)) = 0.32
        [Toggle]_SnowNoiseOnOff("Snow Noise On/Off", Float) = 1
        _SnowNoiseScale("Snow Noise Scale", Range(0,100)) = 87.23351
        _SnowNoiseContrast("Snow Noise Contrast", Range(0,1)) = 0.002

        [HideInInspector]_Vector1("Vector 1", Vector) = (0,1,0,0)

        [Toggle]_TOPPROJECTIONONOFF("TOP PROJECTION ON/OFF", Float) = 0
        [NoScaleOffset]_TopProjectionTexture("Top Projection Texture", 2D) = "white" {}
        _TopProjectionTextureTiling("Top Projection Texture Tiling", Range(0.1,10)) = 0.5
        _TopProjectionTextureCoverage("Top Projection Texture  Coverage", Range(0,1)) = 1

        [HDR]_OreColor("Ore Color", Color) = (1,0.9248579,0,0)
        [Toggle]_OREEMISSIONONOFF("ORE EMISSION ON/OFF", Float) = 0
        [HDR]_OreEmissionColor("Ore Emission Color", Color) = (1,0.9248579,0,0)
        _OreEmissionIntensity("Ore Emission Intensity", Range(0,10)) = 1
        [Toggle]_ANIMATEOREEMISSIONONOFF("ANIMATE ORE  EMISSION ON/OFF", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
            "IsEmissive"="true"
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

            TEXTURE2D(_DetailTexture);
            SAMPLER(sampler_DetailTexture);

            TEXTURE2D(_DecalsTexture);
            SAMPLER(sampler_DecalsTexture);

            TEXTURE2D(_TopProjectionTexture);
            SAMPLER(sampler_TopProjectionTexture);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseTexture_ST;
                float _Smoothness;

                float _GRADIENTONOFF;
                float4 _TopColor;
                float4 _GroundColor;
                float4 _SnowDirection;
                float _Gradient;
                float _GradientPower;
                float _WorldObjectGradient;

                float _DECALSONOFF;
                float4 _DecalsTexture_ST;
                float4 _DecalsColor;

                float _DECALEMISSIONONOFF;
                float4 _DecakEmissionColor;
                float _DecalEmissionIntensity;
                float _ANIMATEDECALEMISSIONONOFF;

                float _DETAILTEXTUREONOFF;
                float _DetailTextureTiling;

                float _SNOWONOFF;
                float _SnowCoverage;
                float _SnowAmount;
                float _SnowFade;
                float _SnowNoiseOnOff;
                float _SnowNoiseScale;
                float _SnowNoiseContrast;

                float4 _Vector1;

                float _TOPPROJECTIONONOFF;
                float _TopProjectionTextureTiling;
                float _TopProjectionTextureCoverage;

                float4 _OreColor;
                float _OREEMISSIONONOFF;
                float4 _OreEmissionColor;
                float _OreEmissionIntensity;
                float _ANIMATEOREEMISSIONONOFF;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 positionOS : TEXCOORD3;
                float3 normalWS : TEXCOORD4;
                float4 color : COLOR;
                float fogCoord : TEXCOORD5;
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

            half4 TriplanarDetail(float3 worldPos, float3 worldNormal, float tiling)
            {
                float3 blend = pow(abs(worldNormal), 1.0);
                blend /= max(blend.x + blend.y + blend.z, 0.0001);

                float3 nsign = sign(worldNormal);

                half4 xProj = SAMPLE_TEXTURE2D(_DetailTexture, sampler_DetailTexture, worldPos.zy * tiling * float2(nsign.x, 1));
                half4 yProj = SAMPLE_TEXTURE2D(_DetailTexture, sampler_DetailTexture, worldPos.xz * tiling * float2(nsign.y, 1));
                half4 zProj = SAMPLE_TEXTURE2D(_DetailTexture, sampler_DetailTexture, worldPos.xy * tiling * float2(-nsign.z, 1));

                return xProj * blend.x + yProj * blend.y + zProj * blend.z;
            }

            half4 TriplanarTopProjection(float3 worldPos, float3 worldNormal, float tiling)
            {
                float3 blend = pow(abs(worldNormal), 1.0);
                blend /= max(blend.x + blend.y + blend.z, 0.0001);

                float3 nsign = sign(worldNormal);

                half4 xProj = SAMPLE_TEXTURE2D(_TopProjectionTexture, sampler_TopProjectionTexture, worldPos.zy * tiling * float2(nsign.x, 1));
                half4 yProj = SAMPLE_TEXTURE2D(_TopProjectionTexture, sampler_TopProjectionTexture, worldPos.xz * tiling * float2(nsign.y, 1));
                half4 zProj = SAMPLE_TEXTURE2D(_TopProjectionTexture, sampler_TopProjectionTexture, worldPos.xy * tiling * float2(-nsign.z, 1));

                return xProj * blend.x + yProj * blend.y + zProj * blend.z;
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionOS = IN.positionOS.xyz;
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionCS = TransformWorldToHClip(OUT.positionWS);

                OUT.uv = IN.uv;
                OUT.uv2 = IN.uv2;
                OUT.color = IN.color;

                OUT.fogCoord = ComputeFogFactor(OUT.positionCS.z);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 baseTex = SAMPLE_TEXTURE2D(_BaseTexture, sampler_BaseTexture, IN.uv);

                float gradientSource = lerp(IN.positionOS.y, IN.positionWS.y, 1.0 - _WorldObjectGradient);

                float gradientMask = saturate(
                    pow(
                        saturate((gradientSource + 1.5) * _Gradient),
                        _GradientPower
                    )
                );

                half3 gradientColor = lerp(_GroundColor.rgb, _TopColor.rgb, gradientMask);

                half3 gradientResult = baseTex.rgb * gradientColor;

                half3 colorResult = lerp(baseTex.rgb, gradientResult, _GRADIENTONOFF);

                half4 detailTex = TriplanarDetail(IN.positionWS, normalize(IN.normalWS), _DetailTextureTiling);
                colorResult = lerp(colorResult, colorResult * detailTex.rgb, _DETAILTEXTUREONOFF);

                half4 decalsTex = SAMPLE_TEXTURE2D(_DecalsTexture, sampler_DecalsTexture, IN.uv2);
                float decalsMask = decalsTex.a;

                colorResult = lerp(colorResult, _DecalsColor.rgb, decalsMask * _DECALSONOFF);

                half4 topProjection = TriplanarTopProjection(IN.positionWS, normalize(IN.normalWS), _TopProjectionTextureTiling);

                float topDot = saturate(dot(normalize(IN.normalWS), normalize(_Vector1.xyz)));
                float topProjectionMask = saturate(
                    pow(
                        abs(topDot * _TopProjectionTextureCoverage * 3.0),
                        5.0
                    )
                );

                colorResult = lerp(colorResult, topProjection.rgb, topProjectionMask * _TOPPROJECTIONONOFF);

                float snowDirectionMask = saturate(dot(normalize(IN.normalWS), normalize(_SnowDirection.xyz)));

                float snowCoverageRemap = lerp(-1.0, 1.0, _SnowCoverage);

                float snowBaseMask = smoothstep(
                    0.0,
                    max(_SnowFade, 0.001),
                    snowCoverageRemap + snowDirectionMask
                );

                float snowNoise = noise2D(IN.positionWS.xz * _SnowNoiseScale);
                snowNoise = saturate(pow(abs(snowNoise), max(_SnowNoiseContrast, 0.001)));

                float snowMask = snowBaseMask * _SnowAmount * _SNOWONOFF;
                snowMask = lerp(snowMask, snowMask * snowNoise, _SnowNoiseOnOff);

                colorResult = lerp(colorResult, half3(1.0, 1.0, 1.0), saturate(snowMask));

                float oreMask = saturate(1.0 - IN.color.a);
                colorResult = lerp(colorResult, _OreColor.rgb, oreMask);

                float3 normalWS = normalize(IN.normalWS);

                Light mainLight = GetMainLight();
                float NdotL = saturate(dot(normalWS, mainLight.direction));

                half3 lighting = mainLight.color * (NdotL * 0.75 + 0.25);

                half3 finalColor = colorResult * lighting;

                float decalPulse = lerp(1.0, (_SinTime.w * 0.3 + 0.5), _ANIMATEDECALEMISSIONONOFF);

                half3 decalEmission =
                    _DecakEmissionColor.rgb *
                    _DecalEmissionIntensity *
                    decalPulse *
                    decalsMask *
                    _DECALEMISSIONONOFF;

                float orePulse = lerp(0.1, (_SinTime.w * 0.3 + 0.5), _ANIMATEOREEMISSIONONOFF);

                half3 oreEmission =
                    _OreEmissionColor.rgb *
                    _OreEmissionIntensity *
                    orePulse *
                    oreMask *
                    _OREEMISSIONONOFF;

                finalColor += decalEmission + oreEmission;

                float3 viewDirWS = normalize(GetWorldSpaceViewDir(IN.positionWS));
                float fresnel = pow(1.0 - saturate(dot(normalWS, viewDirWS)), 3.0);

                finalColor += fresnel * _Smoothness * 0.08;

                finalColor = MixFog(finalColor, IN.fogCoord);

                return half4(finalColor, 1.0);
            }

            ENDHLSL
        }
    }

    Fallback Off
}