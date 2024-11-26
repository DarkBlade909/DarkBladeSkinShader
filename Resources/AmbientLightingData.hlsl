void AmbientLightingData(out half4 R, out half4 G, out half4 B, out half3 ambientCol, out half3 ambientDir)
{
	R = unity_SHAr.xyzw;
	G = unity_SHAg.xyzw;
	B = unity_SHAb.xyzw;
	ambientDir = normalize(unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz);
	ambientCol = float3(R.w,G.w,B.w);
}