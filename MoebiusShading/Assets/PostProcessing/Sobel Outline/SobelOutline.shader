Shader "PostProcessing/SobelOutline"
{
    HLSLINCLUDE
        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
        TEXTURE2D_SAMPLER2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2);
        TEXTURE2D_SAMPLER2D(_CameraGBufferTexture0, sampler_CameraGBufferTexture0);

        float _DepthThreshold;
        float _NormalThreshold;
        float _OutlineThickness;
        float _OutlineDepthMultiplier;
        float _OutlineDepthBias;
        float _OutlineNormalMultiplier;
        float _OutlineNormalBias;
        float _NormalBase;
        float4 _OutlineColor;
    

        float SobelSampleDepth(Texture2D t, SamplerState s, float2 uv, float3 offset)
        {
            float pixelCenter = LinearEyeDepth(t.Sample(s, uv).r);
            float pixelLeft   = LinearEyeDepth(t.Sample(s, uv - offset.xz).r);
            float pixelRight  = LinearEyeDepth(t.Sample(s, uv + offset.xz).r);
            float pixelUp     = LinearEyeDepth(t.Sample(s, uv + offset.zy).r);
            float pixelDown   = LinearEyeDepth(t.Sample(s, uv - offset.zy).r);

            float sobelDepth = abs(pixelCenter-pixelLeft);
            sobelDepth += abs(pixelCenter-pixelRight);
            sobelDepth += abs(pixelCenter-pixelUp);
            sobelDepth += abs(pixelCenter-pixelDown);

            return  sobelDepth;
        }

        float4 SobelSample(Texture2D t, SamplerState s, float2 uv, float3 offset)
        {
            float4 pixelCenter = t.Sample(s, uv);
            float4 pixelLeft   = t.Sample(s, uv - offset.xz);
            float4 pixelRight  = t.Sample(s, uv + offset.xz);
            float4 pixelUp     = t.Sample(s, uv + offset.zy);
            float4 pixelDown   = t.Sample(s, uv - offset.zy);
            
            return abs(pixelLeft  - pixelCenter) +
                   abs(pixelRight - pixelCenter) +
                   abs(pixelUp    - pixelCenter) +
                   abs(pixelDown  - pixelCenter);
        }
    
        float4 FragMain(VaryingsDefault i) : SV_Target
        {
            float depth = _CameraDepthTexture.Sample(sampler_CameraDepthTexture,i.texcoord.xy).r;
            /*float4 sceneColor = _MainTex.Sample(sampler_MainTex,i.texcoord.xy)*/;
            float3 sceneColor = float3(1,1,1);
            if(depth <= 0)
            {
                sceneColor = float3(0.2,0.2,0.8);
            }
            
            float3 outlineColor = lerp(sceneColor, _OutlineColor.rgb, _OutlineColor.a);
            float3 offset = float3((1.0 / _ScreenParams.x), (1.0 / _ScreenParams.y), 0.0) * _OutlineThickness;
            
            float sobelDepth = SobelSampleDepth(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoord.xy, offset).r;
            sobelDepth = step(_DepthThreshold/depth,sobelDepth);

            float3 sobelNormalVec = SobelSample(_CameraGBufferTexture2, sampler_CameraGBufferTexture2, i.texcoord.xy, offset);
            float sobelNormal = length(sobelNormalVec);
            
            sobelNormal = step(_NormalThreshold,sobelNormal);
            
            float sobelOutline = saturate(max(sobelDepth,sobelNormal));
            
            
            
            float3 color = lerp(sceneColor, outlineColor, sobelOutline);
            return float4(color,1);
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