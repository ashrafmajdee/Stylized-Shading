using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;


public class ShadowRenderer : PostProcessEffectRenderer<ShadowSettings>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("PostProcessing/Shadow"));
        
        sheet.properties.SetTexture("_Noise", settings.noise);
        sheet.properties.SetFloat("_NoiseStrength",settings.noiseStrength);
        sheet.properties.SetColor("_ObjectColor", settings.objectColor);
        sheet.properties.SetColor("_ShadowColor", settings.shadowColor);
        sheet.properties.SetColor("_SkyColor", settings.skyColor);
        sheet.properties.SetFloat("_Threshold",settings.shadowThreshold);
        sheet.properties.SetFloat("_NumLines", settings.numLines);
        sheet.properties.SetFloat("_LineThickness", settings.lineThickness);
        
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0); 
    }
    
}
