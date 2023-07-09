Shader "PostProcessing/CombinedOutline"
{
    HLSLINCLUDE
        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_Noise, sampler_Noise);
        TEXTURE2D_SAMPLER2D(_Hatching, sampler_Hatching);
    
        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
        TEXTURE2D_SAMPLER2D(_CameraGBufferTexture0, sampler_CameraGBufferTexture0);
        TEXTURE2D_SAMPLER2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2);
        TEXTURE2D_SAMPLER2D(_CameraGBufferTexture3, sampler_CameraGBufferTexture3);

        float4x4 UNITY_MATRIX_MVP;
        float4x4 _ViewProjectInverse;
        float _OutlineThickness;
        float _NormalSlope;
        float _DepthThreshold;
        float4 _OutlineColor;
        float4 _Color;

        float _HatchingScale;
        float _ShadowThreshold;

        struct TriplanarUV
        {
            float2 xPlane, yPlane, zPlane;
        };

        TriplanarUV GetTriplanarUV (float3 worldPos, float3 normal)
        {
            TriplanarUV triUV;
            triUV.xPlane = worldPos.zy;
            triUV.yPlane = worldPos.xz;
            triUV.zPlane = worldPos.xy;
            if (normal.x < 0) {
		        triUV.xPlane.x = -triUV.xPlane.x;
	        }
	        if (normal.y < 0) {
		        triUV.yPlane.x = -triUV.yPlane.x;
	        }
	        if (normal.z >= 0) {
		        triUV.zPlane.x = -triUV.zPlane.x;
	        }
            return triUV;
        }

        float3 GetTriplanarWeights (float3 normal)
        {
            float3 triW = abs(normal);
            triW /= (triW.x + triW.y + triW.z);
            return triW;
        }
    

        float DoubleStep(float a, float b, float x)
        {
            return 1 - (step(a, x) * (1-step(b, x)));
        }
    
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

        float DoubleSobelSampleDepth(Texture2D t, SamplerState s, float2 uv, float3 offset)
        {
            float pixelCenter = SobelSampleDepth(t,s,uv,offset);
            float pixelLeft   = SobelSampleDepth(t,s,uv - offset.xz,offset);
            float pixelRight  = SobelSampleDepth(t,s,uv + offset.xz,offset);
            float pixelUp     = SobelSampleDepth(t,s,uv + offset.zy,offset);
            float pixelDown   = SobelSampleDepth(t,s,uv - offset.zy,offset);

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

        

        float CalculateShadow(float2 uv)
        {
            float3 baseColor = _CameraGBufferTexture3.Sample(sampler_CameraGBufferTexture3,uv);
            float3 sceneColor = _CameraGBufferTexture0.Sample(sampler_CameraGBufferTexture0,uv);
            float3 shadowColors = baseColor.rgb / sceneColor.rgb;
           
            float shadow = min(shadowColors.r,min(shadowColors.g,shadowColors.b));
            shadow = (1 - step(_ShadowThreshold,shadow));
            return shadow;
        }

        float4 SobelSampleShadow(float2 uv, float3 offset)
        {
            float pixelCenter = CalculateShadow(uv);
            float pixelLeft   = CalculateShadow(uv - offset.xz);
            float pixelRight  = CalculateShadow(uv + offset.xz);
            float pixelUp     = CalculateShadow(uv - offset.zy);
            float pixelDown   = CalculateShadow(uv + offset.zy);
            
            return abs(pixelLeft  - pixelCenter) +
                   abs(pixelRight - pixelCenter) +
                   abs(pixelUp    - pixelCenter) +
                   abs(pixelDown  - pixelCenter);
        }
    
        struct FragInput
        {
            float4 vertex : SV_Position;
            float2 texcoord : TEXCOORD0;
            float3 cameraDir : TEXCOORD1;
        };

        FragInput VertMain(AttributesDefault v)
        {
            FragInput o;
            
            o.vertex   = mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0));
            o.texcoord = TransformTriangleVertexToUV(v.vertex.xy);
            #if UNITY_UV_STARTS_AT_TOP
            o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
            #endif


            // direction of camera in center of screen
            float4 cameraForwardDir = mul(_ViewProjectInverse, float4(0.0, 0.0, 0.5, 1.0));
            cameraForwardDir.xyz /= cameraForwardDir.w;
            cameraForwardDir.xyz -= _WorldSpaceCameraPos;

            //direction of camera at given pixel
            float4 cameraLocalDir = mul(_ViewProjectInverse, float4(o.texcoord.x * 2.0 - 1.0, o.texcoord.y * 2.0 - 1.0, 0.5, 1.0));
            cameraLocalDir.xyz /= cameraLocalDir.w;
            cameraLocalDir.xyz -= _WorldSpaceCameraPos;

            o.cameraDir = cameraLocalDir.xyz / length(cameraForwardDir.xyz);

            

            return o;
        }
    
        float4 FragMain(FragInput i) : SV_Target
        {
            float3 offset = float3((1.0 / _ScreenParams.x), (1.0 / _ScreenParams.y), 0.0);
            float3 sceneColor  = SAMPLE_TEXTURE2D(_CameraGBufferTexture0, sampler_CameraGBufferTexture0, i.texcoord);
            float sceneDepth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoord).r;
            float4 normalTexture = SAMPLE_TEXTURE2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2, i.texcoord);
            float3 sceneNormal = normalTexture.xyz * 2.0 - 1.0;

            float3 toCameraDir = normalize(-i.cameraDir);
            float edge = 0;
            if(sceneDepth > 0)
            {
                float silhouette = dot(toCameraDir, normalize(sceneNormal));
                float3 sobelNormalVec = SobelSample(_CameraGBufferTexture2, sampler_CameraGBufferTexture2, i.texcoord.xy, offset);
                float sobelNormal = length(sobelNormalVec);
                if(silhouette <= _OutlineThickness && sobelNormal > _NormalSlope)
                {
                    edge = 1;
                }
                float depthThreshold = _DepthThreshold;
                float sobelDepth;
                // sobelDepth = SobelSampleDepth(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoord.xy, offset).r;
                float doubleSobelDepth = DoubleSobelSampleDepth(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoord.xy, offset).r;
                sobelDepth = doubleSobelDepth;
                sobelDepth = step(depthThreshold,sobelDepth);
                edge = saturate(max(sobelDepth,edge));
                
                
            }
            else
            {
                sceneColor = _Color;
            }
            

            // hatching and shadows
             
            // hatching is triplanar mapped
            
            /*
            // get triplanar uv for hatching texture
            float linearDepth = LinearEyeDepth(sceneDepth);
            float3 worldPos = (i.cameraDir * linearDepth) + _WorldSpaceCameraPos;
            TriplanarUV triUV = GetTriplanarUV(worldPos,sceneNormal);;
            float hatchingX = SAMPLE_TEXTURE2D(_Hatching,sampler_Hatching,triUV.xPlane * _HatchingScale).r;
            float hatchingY = SAMPLE_TEXTURE2D(_Hatching,sampler_Hatching,triUV.yPlane * _HatchingScale).g;
            float hatchingZ = SAMPLE_TEXTURE2D(_Hatching,sampler_Hatching,triUV.zPlane * _HatchingScale).b;

            //triplanar hatching
            float3 triW = GetTriplanarWeights(sceneNormal);
            float hatching = hatchingX * triW.x + hatchingY * triW.y + hatchingZ * triW.z;
            hatching = step(0.5,hatching);
            */

            //object space hatching

            float hatching = normalTexture.a;

            float shadow = CalculateShadow(i.texcoord);

            float shadowEdge = SobelSampleShadow(i.texcoord,offset);
            
            if(sceneDepth > 0)
            {
                edge = saturate(max(edge, (1-hatching)*shadow));
                edge = saturate(max(edge,shadowEdge));
                if(shadow)
                {
                    sceneColor *= 0.5f;
                }
            }
            
            
            float3 color = lerp(sceneColor, _OutlineColor, edge);
            return float4(color,1);
        }
    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
                #pragma vertex VertMain
                #pragma fragment FragMain
            ENDHLSL
        }
    }
}
