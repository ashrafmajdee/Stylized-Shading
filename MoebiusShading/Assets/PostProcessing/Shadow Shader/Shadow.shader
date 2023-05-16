Shader "PostProcessing/Shadow"
{
    HLSLINCLUDE
        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_Noise,sampler_Noise);
    
        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
        TEXTURE2D_SAMPLER2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2);
        TEXTURE2D_SAMPLER2D(_CameraGBufferTexture3, sampler_CameraGBufferTexture3);
        
        float4 _ObjectColor;
        float4 _ShadowColor;
        float4 _SkyColor;
        float _Threshold;
        float _NumLines;
        float _LineThickness;
        float _NoiseStrength;

        float DoubleStep(float a, float b, float x)
        {
            return 1 - (step(a, x) * (1-step(b, x)));
        }

        float4 FragMain(VaryingsDefault i) : SV_Target
        {
            float depth = _CameraDepthTexture.Sample(sampler_CameraDepthTexture,i.texcoord).r;
            float shadow = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3,i.texcoord).r;
            float4 color = _SkyColor;
            float halfWidth = _LineThickness/2;
            float noiseCoord = i.texcoord.y + (_Noise.Sample(sampler_Noise,i.texcoord).r - 0.5) * _NoiseStrength;
            float hatch = DoubleStep(0.5-halfWidth,0.5+halfWidth,frac(noiseCoord*_NumLines));
            if(depth > 0)
            {
                hatch = (1 - step(_Threshold,shadow)) * hatch;
                color = lerp(_ObjectColor,_ShadowColor,hatch);
            }
            return color;
        }            
    ENDHLSL
    
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
                #pragma vertex VertDefault
                #pragma fragment FragMain
            ENDHLSL
        }
    }
}
