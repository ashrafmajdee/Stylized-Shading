using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class AngleSilhouetteRenderer : PostProcessEffectRenderer<AngleSilhouetteSettings>
{
    public override void Render(PostProcessRenderContext context) 
    {
        var sheet = context.propertySheets.Get(Shader.Find("PostProcessing/SurfaceAngleSilhouetting"));

        sheet.properties.SetMatrix("_ViewProjectInverse", (Camera.current.projectionMatrix * Camera.current.worldToCameraMatrix).inverse);
        sheet.properties.SetFloat("_DepthThreshold", settings.depthThreshold);
        sheet.properties.SetFloat("_OutlineThickness", (settings.thickness));
        sheet.properties.SetFloat("_NormalSlope", settings.normalSlope);
        sheet.properties.SetColor("_OutlineColor", settings.color);

        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);       
    }
}
