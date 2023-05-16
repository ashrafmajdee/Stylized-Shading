using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[PostProcess(typeof(ShadowRenderer),PostProcessEvent.BeforeStack, "Custom/Shadow")]
public class ShadowSettings : PostProcessEffectSettings
{
    public TextureParameter noise = new TextureParameter();
    public FloatParameter noiseStrength = new FloatParameter { value = 0.01f };
    public FloatParameter numLines = new FloatParameter { value = 100f };
    [Range(0,1)]
    public FloatParameter lineThickness = new FloatParameter { value = 0.5f };
    public ColorParameter objectColor = new ColorParameter { value = Color.white };
    public ColorParameter shadowColor = new ColorParameter { value = Color.black };
    public ColorParameter skyColor = new ColorParameter { value = Color.cyan };
    public FloatParameter shadowThreshold = new FloatParameter { value = 0.5f };
}
