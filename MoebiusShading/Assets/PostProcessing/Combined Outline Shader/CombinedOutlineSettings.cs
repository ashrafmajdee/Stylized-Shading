using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[PostProcess(typeof(CombinedOutlineRenderer),PostProcessEvent.AfterStack, "Custom/CombinedOutline")]
public class CombinedOutlineSettings : PostProcessEffectSettings
{
    [Range(0.0f, 1.0f)]
    public FloatParameter thickness = new FloatParameter { value = 0.2f };
    
    [Range(0.0f, 1.0f)]
    public FloatParameter normalSlope = new FloatParameter() { value = 0f };
    
    [Range(0.0f, 1.0f)]
    public FloatParameter depthThreshold = new FloatParameter() { value = 1f };

    public ColorParameter outlineColor = new ColorParameter { value = Color.black }; 
    public ColorParameter color = new ColorParameter { value = Color.white }; 
    
    public TextureParameter noise = new TextureParameter ();
    [Range(0,1)]
    public FloatParameter hatchingThreshold = new FloatParameter { value = 0.5f };
    public FloatParameter shadowThreshold = new FloatParameter { value = 0.5f };
}
