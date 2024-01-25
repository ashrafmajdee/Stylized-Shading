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
    public FloatParameter normalThreshold = new FloatParameter() { value = 0f };
    
    [Range(0.0f, 1.0f)]
    public FloatParameter depthThreshold = new FloatParameter() { value = 1f };

    public ColorParameter outlineColor = new ColorParameter { value = Color.black }; 
    public ColorParameter color = new ColorParameter { value = Color.white }; 
    
    [Range(0.0f, 1.0f)]
    public FloatParameter shadowThreshold = new FloatParameter { value = 0.5f };
}
