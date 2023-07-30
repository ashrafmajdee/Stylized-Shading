using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class CombinedOutlineRenderer : PostProcessEffectRenderer<CombinedOutlineSettings>
{
    public override void Render(PostProcessRenderContext context) 
    {
        var sheet = context.propertySheets.Get(Shader.Find("PostProcessing/CombinedOutline"));

        sheet.properties.SetMatrix("_ViewProjectInverse", (Camera.current.projectionMatrix * Camera.current.worldToCameraMatrix).inverse);
        sheet.properties.SetFloat("_DepthThreshold", settings.depthThreshold);
        sheet.properties.SetFloat("_OutlineThickness", (settings.thickness));
        sheet.properties.SetFloat("_NormalSlope", settings.normalSlope);
        sheet.properties.SetColor("_OutlineColor", settings.outlineColor);
        sheet.properties.SetColor("_Color", settings.color);
        
        sheet.properties.SetFloat("_ShadowThreshold",settings.shadowThreshold);


        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);       
    }
}
