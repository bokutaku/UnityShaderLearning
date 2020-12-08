Shader "Unity Shader Book/Chapter 6/Diffuse Half Lambert"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _HalfLambert ("Half Lambert", Range(0, 1)) = 0.5
    }

    Subshader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                half3 normalWS : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _Diffuse;
                half _HalfLambert;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                // Transform the vertex from object space to projection space
                // in "com.unity.render-pipelines.core\ShaderLibrary\SpaceTransforms.hlsl"
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);

                // Transform the normal from object space to world space
                // in "com.unity.render-pipelines.core\ShaderLibrary\SpaceTransforms.hlsl"
                OUT.normalWS = TransformObjectToWorldNormal(IN.normal);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                // Get ambient term
                // in "com.unity.render-pipelines.universal\ShaderLibrary\UnityInput.hlsl"
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // Get the main light struct
                // in "com.unity.render-pipelines.universal\ShaderLibrary\Lighting.hlsl"
                Light light = GetMainLight();

                // Compute diffuse term.
                half3 normalWS = normalize(IN.normalWS);
                half3 halfLambert = saturate(dot(normalWS, light.direction) * _HalfLambert + (1 - _HalfLambert));
                half3 diffuse = light.color * _Diffuse.rgb * halfLambert;

                return half4(ambient + diffuse, 1.0);
            }
            ENDHLSL
        }
    }

    Fallback "Simple Lit"
}
