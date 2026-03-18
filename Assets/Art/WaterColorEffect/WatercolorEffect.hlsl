#ifndef WATERCOLOR_EFFECT_INCLUDED
#define WATERCOLOR_EFFECT_INCLUDED

// Core.hlsl → declara: Luminance(), real3, half, etc.
// Blit.hlsl → declara: Vert, Varyings, _BlitTexture, _BlitTexture_TexelSize,
//                       sampler_PointClamp, sampler_LinearClamp, sampler_LinearRepeat
// NO redeclarar ninguno de los anteriores.
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

// ─────────────────────────────────────────────
//  Nuestra textura de papel — sampler propio
//  usando inline sampler (nombre codificado)
//  para no colisionar con nada de Blit/Core
// ─────────────────────────────────────────────
TEXTURE2D(_PaperTexture);
// "sampler_linear_repeat" es un inline sampler de Unity (filter=linear, wrap=repeat)
// No lo declara ningún include de URP, así que es seguro.
SamplerState wc_linear_repeat_sampler;

// ─────────────────────────────────────────────
//  Uniforms propios (NO en CBUFFER para evitar
//  conflictos con SRP Batcher en fullscreen pass)
// ─────────────────────────────────────────────
int    _KuwaharaRadius;
float  _EdgeThreshold;
float  _EdgeStrength;
float4 _EdgeColor;
float  _Saturation;
float  _Brightness;
float  _ColorBleed;
float  _PaperStrength;
float  _PaperScale;
float  _PaperWarp;
float  _WetEdgeSpeed;
float  _WetEdgeAmount;
float  _Time_Custom;

// ─────────────────────────────────────────────
//  Helpers — prefijo WC_ para evitar colisión
//  con funciones de Core.hlsl (Luminance, etc.)
// ─────────────────────────────────────────────
float WC_Lum(float3 c)
{
    return dot(c, float3(0.299, 0.587, 0.114));
}

float3 WC_AdjSat(float3 c, float sat)
{
    float lum = WC_Lum(c);
    return lerp(float3(lum, lum, lum), c, sat);
}

float WC_Hash(float2 p)
{
    p = frac(p * float2(127.1, 311.7));
    p += dot(p, p + 19.19);
    return frac(p.x * p.y);
}

float WC_Noise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    return lerp(
        lerp(WC_Hash(i),               WC_Hash(i + float2(1,0)), u.x),
        lerp(WC_Hash(i + float2(0,1)), WC_Hash(i + float2(1,1)), u.x),
        u.y);
}

// ─────────────────────────────────────────────
//  Muestreo de la escena
//  Usamos sampler_PointClamp (declarado en Blit.hlsl)
//  con bilinear conseguido vía sampler_LinearClamp
//  (también declarado en Blit.hlsl) — ninguno de los dos
//  lo necesitamos declarar nosotros.
// ─────────────────────────────────────────────
float3 WC_Sample(float2 uv)
{
    // sampler_LinearClamp ya está en Blit.hlsl, solo lo usamos
    return SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv).rgb;
}

// ─────────────────────────────────────────────
//  Kuwahara Filter
// ─────────────────────────────────────────────
float3 KuwaharaFilter(float2 uv, int radius)
{
    float2 texel = _BlitTexture_TexelSize.xy;

    float3 mean[4] = { (float3)0, (float3)0, (float3)0, (float3)0 };
    float3 sq[4]   = { (float3)0, (float3)0, (float3)0, (float3)0 };
    float  cnt[4]  = { 0, 0, 0, 0 };

    for (int j = -radius; j <= radius; j++)
    {
        for (int i = -radius; i <= radius; i++)
        {
            float3 col = WC_Sample(uv + float2(i, j) * texel);
            if (i <= 0 && j <= 0) { mean[0]+=col; sq[0]+=col*col; cnt[0]++; }
            if (i >= 0 && j <= 0) { mean[1]+=col; sq[1]+=col*col; cnt[1]++; }
            if (i <= 0 && j >= 0) { mean[2]+=col; sq[2]+=col*col; cnt[2]++; }
            if (i >= 0 && j >= 0) { mean[3]+=col; sq[3]+=col*col; cnt[3]++; }
        }
    }

    float  minVar = 1e9;
    float3 result = (float3)0;

    UNITY_UNROLL
    for (int k = 0; k < 4; k++)
    {
        float3 m = mean[k] / cnt[k];
        float3 v = abs(sq[k] / cnt[k] - m * m);
        float  variance = v.r + v.g + v.b;
        if (variance < minVar) { minVar = variance; result = m; }
    }
    return result;
}

// ─────────────────────────────────────────────
//  Edge Detection (Sobel)
// ─────────────────────────────────────────────
float DetectEdges(float2 uv)
{
    float2 d = _BlitTexture_TexelSize.xy;
    float tl = WC_Lum(WC_Sample(uv + float2(-d.x,  d.y)));
    float tm = WC_Lum(WC_Sample(uv + float2( 0.0,  d.y)));
    float tr = WC_Lum(WC_Sample(uv + float2( d.x,  d.y)));
    float ml = WC_Lum(WC_Sample(uv + float2(-d.x,  0.0)));
    float mr = WC_Lum(WC_Sample(uv + float2( d.x,  0.0)));
    float bl = WC_Lum(WC_Sample(uv + float2(-d.x, -d.y)));
    float bm = WC_Lum(WC_Sample(uv + float2( 0.0, -d.y)));
    float br = WC_Lum(WC_Sample(uv + float2( d.x, -d.y)));
    float gx = -tl - 2.0*ml - bl + tr + 2.0*mr + br;
    float gy = -tl - 2.0*tm - tr + bl + 2.0*bm + br;
    return sqrt(gx*gx + gy*gy);
}

// ─────────────────────────────────────────────
//  Wet Edge / Color Bleed
// ─────────────────────────────────────────────
float3 WetEdgeBleed(float2 uv, float edge, float amount)
{
    float2 texel = _BlitTexture_TexelSize.xy;
    float3 bleed = (float3)0;
    float  total = 0.0;

    UNITY_UNROLL
    for (int i = 0; i < 4; i++)
    {
        float o = (float)(i + 1) + 0.5;
        float w = (4.0 - i) * 0.25;
        bleed += WC_Sample(uv + float2( o,  0) * texel) * w;
        bleed += WC_Sample(uv + float2(-o,  0) * texel) * w;
        bleed += WC_Sample(uv + float2( 0,  o) * texel) * w;
        bleed += WC_Sample(uv + float2( 0, -o) * texel) * w;
        total += w * 4.0;
    }
    bleed /= total;
    return lerp(WC_Sample(uv), bleed, saturate(edge * amount * 3.0));
}

// ─────────────────────────────────────────────
//  Paper Overlay (procedural)
// ─────────────────────────────────────────────
float3 ApplyPaper(float3 color, float2 uv, float scale, float strength)
{
    float2 p    = uv * scale * 8.0;
    float paper = WC_Noise(p)       * 0.50
                + WC_Noise(p * 2.0) * 0.30
                + WC_Noise(p * 4.0) * 0.15
                + WC_Noise(p * 8.0) * 0.05;
    paper = saturate(paper);
    float3 paperColor = lerp(float3(0.85, 0.80, 0.72), float3(1.0, 0.97, 0.93), paper);
    return lerp(color, color * paperColor, strength);
}

// ─────────────────────────────────────────────
//  UV Warp
// ─────────────────────────────────────────────
float2 WarpUV(float2 uv, float amount)
{
    float t  = _Time_Custom * _WetEdgeSpeed;
    float wx = WC_Noise(uv * 6.0 + float2(t * 0.3, 0.0)) - 0.5;
    float wy = WC_Noise(uv * 6.0 + float2(0.0, t * 0.4)) - 0.5;
    return uv + float2(wx, wy) * amount;
}

// ─────────────────────────────────────────────
//  Fragment Principal
// ─────────────────────────────────────────────
float4 WatercolorFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    float2 uv = input.texcoord;

    float2 warpedUV  = WarpUV(uv, _PaperWarp);
    float3 painted   = KuwaharaFilter(warpedUV, _KuwaharaRadius);
    float  edge      = DetectEdges(uv);
           edge      = smoothstep(_EdgeThreshold - 0.05, _EdgeThreshold + 0.05, edge);
    float3 bled      = WetEdgeBleed(warpedUV, edge, _ColorBleed);
           painted   = lerp(painted, bled, saturate(_ColorBleed));
    float3 finalColor = lerp(painted, painted * _EdgeColor.rgb, edge * _EdgeStrength);
           finalColor = WC_AdjSat(finalColor, _Saturation);
           finalColor *= _Brightness;
           finalColor = ApplyPaper(finalColor, uv, _PaperScale, _PaperStrength);
           finalColor = lerp(finalColor, finalColor * float3(1.04, 1.01, 0.96), 0.4);

    return float4(finalColor, 1.0);
}

#endif // WATERCOLOR_EFFECT_INCLUDED
