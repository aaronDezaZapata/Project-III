using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// Volume component para el Watercolor Art Painting Stylization Effect.
/// Añade a un Global Volume en la escena.
/// </summary>
[System.Serializable]
[VolumeComponentMenu("Custom/Watercolor Effect")]
[SupportedOnRenderPipeline(typeof(UniversalRenderPipelineAsset))]
public class WatercolorVolume : VolumeComponent, IPostProcessComponent
{
    [Header("Kuwahara Painterly Filter")]
    [Tooltip("Tamaño del kernel Kuwahara. Más alto = más pictórico y más costoso.")]
    public ClampedIntParameter kuwaharaRadius = new(3, 1, 6);

    [Header("Edge — Ink Lines")]
    [Tooltip("Umbral de gradiente de luminancia para dibujar borde.")]
    public ClampedFloatParameter edgeThreshold = new(0.20f, 0.01f, 1.0f);

    [Tooltip("Opacidad de las líneas de tinta.")]
    public ClampedFloatParameter edgeStrength  = new(0.60f, 0.0f, 1.0f);

    [Tooltip("Color del contorno (marrón oscuro, tinta china, etc).")]
    public ColorParameter edgeColor = new(new Color(0.12f, 0.08f, 0.05f, 1f), true, false, true);

    [Header("Color Grading")]
    [Tooltip("Viveza del color. 1.1–1.3 = look acuarela saturada.")]
    public ClampedFloatParameter saturation = new(1.15f, 0.0f, 2.0f);

    [Tooltip("Brillo general.")]
    public ClampedFloatParameter brightness  = new(1.00f, 0.5f, 1.5f);

    [Tooltip("Cuánto sangra el color en bordes (wet paint).")]
    public ClampedFloatParameter colorBleed  = new(0.35f, 0.0f, 1.0f);

    [Header("Paper Texture")]
    [Tooltip("Intensidad del grano de papel.")]
    public ClampedFloatParameter paperStrength = new(0.45f, 0.0f, 1.0f);

    [Tooltip("Escala / tiling del papel.")]
    public ClampedFloatParameter paperScale    = new(4.0f,  0.5f, 20.0f);

    [Header("Paper Warp & Wetness")]
    [Tooltip("Distorsión UV que simula papel húmedo.")]
    public ClampedFloatParameter paperWarp     = new(0.004f, 0.0f, 0.02f);

    [Tooltip("Velocidad de la animación de warp (0 = estático).")]
    public ClampedFloatParameter wetEdgeSpeed  = new(0.30f,  0.0f, 2.0f);

    [Tooltip("Intensidad del efecto de bordes húmedos.")]
    public ClampedFloatParameter wetEdgeAmount = new(0.50f,  0.0f, 1.0f);

    public bool IsActive()         => active;
    public bool IsTileCompatible() => false;
}
