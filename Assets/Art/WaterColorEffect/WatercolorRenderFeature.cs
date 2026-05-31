using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule; // Unity 6 / URP 17

/// <summary>
/// URP Render Feature — Watercolor Art Painting Stylization Effect
/// Compatible con Unity 6 + URP 17 (RenderGraph)
/// </summary>
[DisallowMultipleRendererFeature("Watercolor Effect")]
public class WatercolorRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        [Tooltip("Material usando el shader Custom/WatercolorEffect.")]
        public Material material;

        [Tooltip("Momento de inyección en el frame.")]
        public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public Settings settings = new();
    private WatercolorPass _pass;

    public override void Create()
    {
        _pass = new WatercolorPass(settings.material, settings.renderPassEvent);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.material == null)
        {
            Debug.LogWarning("[WatercolorEffect] Asigna un Material en el Renderer Feature.");
            return;
        }

        var cameraType = renderingData.cameraData.cameraType;
        if (cameraType == CameraType.Preview || cameraType == CameraType.Reflection) return;

        var stack  = VolumeManager.instance.stack;
        var volume = stack.GetComponent<WatercolorVolume>();
        if (volume == null || !volume.IsActive()) return;

        _pass.UpdateMaterial(settings.material, volume);
        renderer.EnqueuePass(_pass);
    }

    protected override void Dispose(bool disposing)
    {
        _pass?.Dispose();
    }

    // ═══════════════════════════════════════════════════════
    //  Pass
    // ═══════════════════════════════════════════════════════
    private class WatercolorPass : ScriptableRenderPass, System.IDisposable
    {
        private Material _material;

        private static readonly int s_timeID         = Shader.PropertyToID("_Time_Custom");
        private static readonly int s_kuwaharaRadius = Shader.PropertyToID("_KuwaharaRadius");
        private static readonly int s_edgeThreshold  = Shader.PropertyToID("_EdgeThreshold");
        private static readonly int s_edgeStrength   = Shader.PropertyToID("_EdgeStrength");
        private static readonly int s_edgeColor      = Shader.PropertyToID("_EdgeColor");
        private static readonly int s_saturation     = Shader.PropertyToID("_Saturation");
        private static readonly int s_brightness     = Shader.PropertyToID("_Brightness");
        private static readonly int s_colorBleed     = Shader.PropertyToID("_ColorBleed");
        private static readonly int s_paperStrength  = Shader.PropertyToID("_PaperStrength");
        private static readonly int s_paperScale     = Shader.PropertyToID("_PaperScale");
        private static readonly int s_paperWarp      = Shader.PropertyToID("_PaperWarp");
        private static readonly int s_wetEdgeSpeed   = Shader.PropertyToID("_WetEdgeSpeed");
        private static readonly int s_wetEdgeAmount  = Shader.PropertyToID("_WetEdgeAmount");

        public WatercolorPass(Material mat, RenderPassEvent evt)
        {
            _material        = mat;
            renderPassEvent  = evt;
            profilingSampler = new ProfilingSampler("Watercolor Effect");
        }

        public void UpdateMaterial(Material mat, WatercolorVolume v)
        {
            _material = mat;
            mat.SetInt  (s_kuwaharaRadius, v.kuwaharaRadius.value);
            mat.SetFloat(s_edgeThreshold,  v.edgeThreshold.value);
            mat.SetFloat(s_edgeStrength,   v.edgeStrength.value);
            mat.SetColor(s_edgeColor,      v.edgeColor.value);
            mat.SetFloat(s_saturation,     v.saturation.value);
            mat.SetFloat(s_brightness,     v.brightness.value);
            mat.SetFloat(s_colorBleed,     v.colorBleed.value);
            mat.SetFloat(s_paperStrength,  v.paperStrength.value);
            mat.SetFloat(s_paperScale,     v.paperScale.value);
            mat.SetFloat(s_paperWarp,      v.paperWarp.value);
            mat.SetFloat(s_wetEdgeSpeed,   v.wetEdgeSpeed.value);
            mat.SetFloat(s_wetEdgeAmount,  v.wetEdgeAmount.value);
            mat.SetFloat(s_timeID,         Time.time);
        }

        // ── RenderGraph (Unity 6 / URP 17) ──────────────────────────────
        private class PassData
        {
            public TextureHandle src;
            public Material      mat;
        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            var resourceData = frameData.Get<UniversalResourceData>();
            var cameraData   = frameData.Get<UniversalCameraData>();

            if (resourceData.isActiveTargetBackBuffer) return;

            var srcHandle = resourceData.activeColorTexture;

            var desc = cameraData.cameraTargetDescriptor;
            desc.msaaSamples     = 1;
            desc.depthBufferBits = 0;

            var dstHandle = UniversalRenderer.CreateRenderGraphTexture(
                renderGraph, desc, "_WatercolorTemp", false);

            // Pass 1: blit con efecto → temp
            using (var builder = renderGraph.AddRasterRenderPass<PassData>(
                "Watercolor Blit", out var data, profilingSampler))
            {
                data.src = srcHandle;
                data.mat = _material;

                builder.UseTexture(srcHandle);
                builder.SetRenderAttachment(dstHandle, 0);
                builder.SetRenderFunc(static (PassData d, RasterGraphContext ctx) =>
                {
                    Blitter.BlitTexture(ctx.cmd, d.src, new Vector4(1, 1, 0, 0), d.mat, 0);
                });
            }

            // Pass 2: copiar temp de vuelta al color buffer de cámara
            using (var builder = renderGraph.AddRasterRenderPass<PassData>(
                "Watercolor CopyBack", out var data, profilingSampler))
            {
                data.src = dstHandle;
                data.mat = null;

                builder.UseTexture(dstHandle);
                builder.SetRenderAttachment(resourceData.activeColorTexture, 0);
                builder.SetRenderFunc(static (PassData d, RasterGraphContext ctx) =>
                {
                    Blitter.BlitTexture(ctx.cmd, d.src, new Vector4(1, 1, 0, 0), 0, false);
                });
            }
        }

        public void Dispose() { }
    }
}
