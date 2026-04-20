// Converted to URP
Shader "VaxKun/FancyFootsteps"
{
    Properties
    {
        _Cutoff( "Mask Clip Value", Float ) = 0.5
        _NoiseScale("NoiseScale", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
    }

    SubShader
    {
        Tags { 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
            "Queue" = "AlphaTest+0" 
        }
        Cull Off

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float _Cutoff;
            float _NoiseScale;
        CBUFFER_END

        float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
        float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
        float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

        float snoise( float2 v )
        {
            const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
            float2 i = floor( v + dot( v, C.yy ) );
            float2 x0 = v - i + dot( i, C.xx );
            float2 i1;
            i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
            float4 x12 = x0.xyxy + C.xxzz;
            x12.xy -= i1;
            i = mod2D289( i );
            float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
            float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
            m = m * m;
            m = m * m;
            float3 x = 2.0 * frac( p * C.www ) - 1.0;
            float3 h = abs( x ) - 0.5;
            float3 ox = floor( x + 0.5 );
            float3 a0 = x - ox;
            m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
            float3 g;
            g.x = a0.x * x0.x + h.x * x0.y;
            g.yz = a0.yz * x12.xz + h.yz * x12.yw;
            return 130.0 * dot( m, g );
        }
        ENDHLSL

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float4 color        : COLOR;
                float3 normalOS     : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float3 positionOS   : TEXCOORD0;
                float4 color        : COLOR;
                float3 normalWS     : NORMAL;
                float fogCoord      : TEXCOORD1;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionOS = input.positionOS.xyz;
                output.color = input.color;
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.fogCoord = ComputeFogFactor(output.positionHCS.z);
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float simplePerlin2D3 = snoise(input.positionOS.xy * _NoiseScale);
                simplePerlin2D3 = simplePerlin2D3 * 0.5 + 0.5;
                float clampResult11 = clamp(step(simplePerlin2D3, input.color.a), 0.0, 1.0);
                clip(clampResult11 - _Cutoff);

                float3 albedo = input.color.rgb;

                Light mainLight = GetMainLight();
                float NdotL = saturate(dot(normalize(input.normalWS), mainLight.direction));
                float3 lighting = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation * NdotL);
                
                lighting += SampleSH(input.normalWS);

                float4 finalColor = float4(albedo * lighting, 1.0);
                finalColor.rgb = MixFog(finalColor.rgb, input.fogCoord);
                
                return finalColor;
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ColorMask 0

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float4 color        : COLOR;
                float3 normalOS     : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float3 positionOS   : TEXCOORD0;
                float4 color        : COLOR;
            };

            float3 _LightDirection;
            float3 _LightPosition;

            Varyings vert(Attributes input)
            {
                Varyings output;
                
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

                #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
                #else
                    float3 lightDirectionWS = _LightDirection;
                #endif

                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

                #if UNITY_REVERSED_Z
                    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #else
                    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #endif

                output.positionHCS = positionCS;
                output.positionOS = input.positionOS.xyz;
                output.color = input.color;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float simplePerlin2D3 = snoise(input.positionOS.xy * _NoiseScale);
                simplePerlin2D3 = simplePerlin2D3 * 0.5 + 0.5;
                float clampResult11 = clamp(step(simplePerlin2D3, input.color.a), 0.0, 1.0);
                clip(clampResult11 - _Cutoff);

                return 0;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ColorMask 0

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float4 color        : COLOR;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float3 positionOS   : TEXCOORD0;
                float4 color        : COLOR;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionOS = input.positionOS.xyz;
                output.color = input.color;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float simplePerlin2D3 = snoise(input.positionOS.xy * _NoiseScale);
                simplePerlin2D3 = simplePerlin2D3 * 0.5 + 0.5;
                float clampResult11 = clamp(step(simplePerlin2D3, input.color.a), 0.0, 1.0);
                clip(clampResult11 - _Cutoff);

                return 0;
            }
            ENDHLSL
        }
    }
    Fallback "Hidden/Universal Render Pipeline/FallbackError"
    // ASE CustomEditor keeping in case it's helpful
    CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18300
13.6;46.4;1685;1000;1473.97;516.1983;1.379063;True;False
Node;AmplifyShaderEditor.RangedFloatNode;8;-646.2937,383.5911;Inherit;False;Property;_NoiseScale;NoiseScale;1;0;Create;True;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;5;-663.3294,154.5187;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;1;-372.9944,-14.09834;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;3;-432.077,244.3094;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;9;-105.1824,248.8675;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;11;156.7597,262.6256;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;2;92.36308,1.555097;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;369.2021,1.516253;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;VaxKun/FancyFootsteps;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;5;0
WireConnection;3;1;8;0
WireConnection;9;0;3;0
WireConnection;9;1;1;4
WireConnection;11;0;9;0
WireConnection;2;0;1;1
WireConnection;2;1;1;2
WireConnection;2;2;1;3
WireConnection;0;0;2;0
WireConnection;0;10;11;0
ASEEND*/
//CHKSM=35D0FE3DC9582A5910A300BAD349AAE5C47EC882