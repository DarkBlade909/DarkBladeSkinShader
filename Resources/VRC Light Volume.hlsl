half3 SHEvalLinearL2_1 (half4 normal)
{
    half3 x1, x2;
    // 4 of the quadratic (L2) polynomials
    half4 vB = normal.xyzz * normal.yzzx;
    x1.r = dot(unity_SHBr,vB);
    x1.g = dot(unity_SHBg,vB);
    x1.b = dot(unity_SHBb,vB);

    // Final (5th) quadratic (L2) polynomial
    half vC = normal.x*normal.x - normal.y*normal.y;
    x2 = unity_SHC.rgb * vC;

    return x1 + x2;
}

void VRCLightVolume(float3 NormalWS, float3 PositionWS, out float3 Diffuse, out float3 AmbientDir, out float3 AmbientCol, out float3 R, out float3 G, out float3 B)
{

    float3 L0, L1r, L1g, L1b;
    #ifdef PREVIEW
        Diffuse = 0.15;
        AmbientDir = 0;
        AmbientCol = 0;
        R = 0;
        G = 0;
        B = 0;
    #else
        LightVolumeSH(PositionWS, L0, L1r, L1g, L1b);
        Diffuse = LightVolumeEvaluate(NormalWS, L0, L1r, L1g, L1b);
        if(_UdonLightVolumeEnabled < 1.0) {
            Diffuse += SHEvalLinearL2_1(float4(NormalWS,1.0));
        }
        AmbientDir = normalize(L1r+L1g+L1b);
        AmbientCol = Diffuse;
        R = L1r;
        G = L1g;
        B = L1b;
    #endif
}