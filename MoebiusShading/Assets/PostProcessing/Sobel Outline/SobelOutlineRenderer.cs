using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public sealed class SobelOutlineRenderer : PostProcessEffectRenderer<SobelOutlineSettings>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("PostProcessing/SobelOutline"));

        sheet.properties.SetFloat("_OutlineThickness", settings.thickness);
        sheet.properties.SetFloat("_NormalThreshold", settings.normalThreshold);
        sheet.properties.SetFloat("_DepthThreshold", settings.depthThreshold);
        sheet.properties.SetColor("_OutlineColor", settings.color);
        sheet.properties.SetFloat("_NormalBase", settings.normalBase);

        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
