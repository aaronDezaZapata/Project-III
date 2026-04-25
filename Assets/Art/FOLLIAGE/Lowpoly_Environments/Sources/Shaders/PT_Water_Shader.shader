Shader "Polytope Studio/PT_Water_Shader"
{
    Properties
    {
        _DeepColor("Deep Color", Color) = (0.3114988,0.5266015,0.5283019,0.55)
        _ShallowColor("Shallow Color", Color) = (0.5238074,0.7314408,0.745283,0.45)

        _Depth("Depth", Range(0,1)) = 0.3
        _DepthStrength("Depth Strength", Range(0,1)) = 0.3

        _Smootness("Smootness", Range(0,1)) = 1
        _Mettalic("Mettalic", Range(0,1)) = 0

        _TessValue("Max Tessellation", Range(1,32)) = 5

        _WaveSpeed("Wave Speed", Range(0,1)) = 0.5
        _WaveTile("Wave Tile", Range(0,0.9)) = 0.5
        _WaveAmplitude("Wave Amplitude", Range(0,1)) = 0.2

        [NoScaleOffset][Normal]_NormalMapTexture("Normal Map Texture", 2D) = "bump" {}
        _NormalMapWavesSpeed("Normal Map Waves Speed", Range(0,1)) = 0.1
        _NormalMapsWavesSize("Normal Maps Waves Size", Range(0,10)) = 5

        _FoamColor("Foam Color", Color) = (0.3066038,1,0.9145772,1)
        _FoamAmount("Foam Amount", Range(0.01,10)) = 1.5
        _FoamPower("Foam Power", Range(0.1,5)) = 0.5
        _FoamNoiseScale("Foam Noise Scale", Range(0,1000)) = 150

        _Transparency("Transparency", Range(0,1)) = 0.55
        _RefractionStrength("Refraction Strength", Range(0,0.1)) = 0.025

        [HideInInspector]_texcoord("", 2D) = "white" {}
        [HideInInspector]__dirty("", Int) = 1

        [Header(Forward Rendering Options)]
        [ToggleOff]_GlossyReflections("Reflections", Float) = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "IgnoreProjector"="True"
        }

        Cull Off
        ZWrite Off
        ZTest LEqual
        Blend SrcAlpha OneMinusSrcAlpha

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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            TEXTURE2D(_NormalMapTexture);
            SAMPLER(sampler_NormalMapTexture);

            CBUFFER_START(UnityPerMaterial)
                float4 _DeepColor;
                float4 _ShallowColor;

                float _Depth;
                float _DepthStrength;

                float _Smootness;
                float _Mettalic;
                float _TessValue;

                float _WaveSpeed;
                float _WaveTile;
                float _WaveAmplitude;

                float _NormalMapWavesSpeed;
                float _NormalMapsWavesSize;

                float4 _FoamColor;
                float _FoamAmount;
                float _FoamPower;
                float _FoamNoiseScale;

                float _Transparency;
                float _RefractionStrength;
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
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
                float4 screenPos : TEXCOORD3;
                float eyeDepth : TEXCOORD4;
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

            float gradientNoise(float2 uv)
            {
                float n = noise2D(uv);
                n += noise2D(uv * 2.0) * 0.5;
                n += noise2D(uv * 4.0) * 0.25;
                return saturate(n / 1.75);
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                float3 posOS = IN.positionOS.xyz;
                float3 posWS = TransformObjectToWorld(posOS);

                float2 waveUV =
                    posWS.xz * float2(6.5, 0.9) * _WaveTile +
                    _Time.y * _WaveSpeed * float2(0.23, -0.8);

                float waveNoise = noise2D(waveUV);
                waveNoise = waveNoise * 0.5 + 0.5;

                float waveOffset = 0.05 * _WaveAmplitude * waveNoise;

                posOS.y += waveOffset;

                OUT.positionWS = TransformObjectToWorld(posOS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionCS = TransformWorldToHClip(OUT.positionWS);
                OUT.screenPos = ComputeScreenPos(OUT.positionCS);

                float3 positionVS = TransformWorldToView(OUT.positionWS);
                OUT.eyeDepth = -positionVS.z;

                OUT.uv = IN.uv;
                OUT.fogCoord = ComputeFogFactor(OUT.positionCS.z);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 screenUV = IN.screenPos.xy / IN.screenPos.w;

                float rawSceneDepth = SampleSceneDepth(screenUV);
                float sceneEyeDepth = LinearEyeDepth(rawSceneDepth, _ZBufferParams);

                float depthDifference = max(sceneEyeDepth - IN.eyeDepth, 0.0);

                float depthMask = saturate((depthDifference + _Depth) * _DepthStrength);

                half3 waterColor = lerp(_ShallowColor.rgb, _DeepColor.rgb, depthMask);

                float2 normalUV =
                    IN.uv * _NormalMapsWavesSize +
                    _Time.y * _NormalMapWavesSpeed * float2(0.1, 0.1);

                half3 normalSample = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMapTexture, sampler_NormalMapTexture, normalUV));

                float2 refractionOffset = normalSample.xy * _RefractionStrength * saturate(depthDifference);

                half3 sceneColor = SampleSceneColor(screenUV + refractionOffset);

                half3 refractedColor = lerp(sceneColor, waterColor, 0.62);

                float foamDepth = saturate(1.0 - depthDifference / max(_FoamAmount, 0.001));

                float2 foamUV =
                    IN.uv * _FoamNoiseScale +
                    _Time.y * float2(0.2, 0.2);

                float foamNoise = gradientNoise(foamUV);

                float foamMask = step(pow(saturate(1.0 - foamDepth), _FoamPower), foamNoise) * foamDepth;

                half3 finalColor = refractedColor + (_FoamColor.rgb * foamMask);

                float3 normalWS = normalize(float3(normalSample.x, 1.0, normalSample.y));
                float3 viewDirWS = normalize(GetWorldSpaceViewDir(IN.positionWS));

                Light mainLight = GetMainLight();
                float NdotL = saturate(dot(normalWS, mainLight.direction));

                half3 lighting = mainLight.color * (NdotL * 0.45 + 0.55);

                finalColor *= lighting;

                float fresnel = pow(1.0 - saturate(dot(normalWS, viewDirWS)), 3.0);
                finalColor += fresnel * _Smootness * 0.35;

                finalColor = MixFog(finalColor, IN.fogCoord);

                float alpha = saturate(_Transparency + depthMask * 0.35 + foamMask * 0.15);

                return half4(finalColor, alpha);
            }

            ENDHLSL
        }
    }

    Fallback Off
}