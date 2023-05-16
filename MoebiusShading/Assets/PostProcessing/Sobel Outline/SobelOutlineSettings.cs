using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[PostProcess(typeof(SobelOutlineRenderer), PostProcessEvent.BeforeStack, "Custom/SobelOutline")]
public class SobelOutlineSettings : PostProcessEffectSettings
{
    
    public FloatParameter thickness = new FloatParameter { value = 1.0f };
    public FloatParameter depthThreshold = new FloatParameter { value = 1.0f };
    public FloatParameter normalThreshold = new FloatParameter { value = 1.0f };
    public ColorParameter color = new ColorParameter { value = Color.black };
    public FloatParameter normalBase = new FloatParameter { value = 2.0f };
}
