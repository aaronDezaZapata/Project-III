Shader "Custom/WatercolorEffect"
{
    Properties
    {
        // Kuwahara
        [Header(Kuwahara Painterly Filter)]
        [Space(5)]
        _KuwaharaRadius     ("Radius (2-6)",              Range(1, 6))      = 3

        // Edges
        [Header(Edge _ Ink Lines)]
        [Space(5)]
        _EdgeThreshold      ("Edge Threshold",            Range(0.01, 1.0)) = 0.2
        _EdgeStrength       ("Edge Strength",             Range(0.0, 1.0))  = 0.6
        _EdgeColor          ("Edge Color",                Color)            = (0.12, 0.08, 0.05, 1)

        // Color
        [Header(Color Grading)]
        [Space(5)]
        _Saturation         ("Saturation",                Range(0.0, 2.0))  = 1.15
        _Brightness         ("Brightness",                Range(0.5, 1.5))  = 1.0
        _ColorBleed         ("Color Bleed (Wet Edges)",   Range(0.0, 1.0))  = 0.35

        // Paper
        [Header(Paper Texture)]
        [Space(5)]
        [Toggle(_USE_PAPER_TEXTURE)] _UsePaperTex ("Use Paper Texture", Float) = 0
        _PaperTexture       ("Paper Texture (optional)",  2D)               = "white" {}
        _PaperStrength      ("Paper Strength",            Range(0.0, 1.0))  = 0.45
        _PaperScale         ("Paper Tiling Scale",        Range(0.5, 20.0)) = 4.0

        // Wetness
        [Header(Paper Warp _ Wetness)]
        [Space(5)]
        _PaperWarp          ("Paper Warp Amount",         Range(0.0, 0.02)) = 0.004
        _WetEdgeSpeed       ("Warp Animation Speed",      Range(0.0, 2.0))  = 0.3
        _WetEdgeAmount      ("Wet Edge Intensity",        Range(0.0, 1.0))  = 0.5
        _Time_Custom        ("Time (auto-set)",           Float)            = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType"      = "Opaque"
            "RenderPipeline"  = "UniversalPipeline"
        }

        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            Name "WatercolorPass"

            HLSLPROGRAM
            #pragma vertex   Vert
            #pragma fragment WatercolorFragment
            #pragma shader_feature_local _USE_PAPER_TEXTURE

            #include "WatercolorEffect.hlsl"
            ENDHLSL
        }
    }
    FallBack Off
}
