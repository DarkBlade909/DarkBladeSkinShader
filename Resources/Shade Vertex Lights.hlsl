float pow5_vertex(float x)
{
	float x2 = x * x;
	return x2 * x2 * x;
}

half3 F_Schlick_vertex(half u, half3 f0)
{
	return f0 + (1.0 - f0) * pow(1.0 - u, 5.0);
}

float F_Schlick_vertex(float f0, float f90, float VoH)
{
	return f0 + (f90 - f0) * pow5_vertex(1.0 - VoH);
}

half Fd_Burley_vertex(half roughness, half NoV, half NoL, half LoH)
{
	// Burley 2012, "Physically-Based Shading at Disney"
	half f90 = 0.5 + 2.0 * roughness * LoH * LoH;
	float lightScatter = F_Schlick_vertex(1.0, f90, NoL);
	float viewScatter  = F_Schlick_vertex(1.0, f90, NoV);
	return lightScatter * viewScatter;
}

half D_GGX_vertex(half NoH, half roughness)
{
	half a = NoH * roughness;
	half k = roughness / (1.0 - NoH * NoH + a * a);
	return k * k * (1.0 / PI);
}

float D_GGX_Anisotropic_vertex(float NoH, float3 h, float3 t, float3 b, float at, float ab)
{
	half ToH = dot(t, h);
	half BoH = dot(b, h);
	half a2 = at * ab;
	float3 v = float3(ab * ToH, at * BoH, a2 * NoH);
	float v2 = dot(v, v);
	half w2 = a2 / v2;
	return a2 * w2 * w2 * (1.0 / PI);
}

float V_SmithGGXCorrelatedFast_vertex(half NoV, half NoL, half roughness)
{
	half a = roughness;
	float GGXV = NoL * (NoV * (1.0 - a) + a);
	float GGXL = NoV * (NoL * (1.0 - a) + a);
	return 0.5 / (GGXV + GGXL);
}

float V_SmithGGXCorrelated_vertex(half NoV, half NoL, half roughness)
{
	#ifdef QUALITY_LOW
		return V_SmithGGXCorrelatedFast_vertex(NoV, NoL, roughness);
	#else
		half a2 = roughness * roughness;
		float GGXV = NoL * sqrt(NoV * NoV * (1.0 - a2) + a2);
		float GGXL = NoV * sqrt(NoL * NoL * (1.0 - a2) + a2);
		return 0.5 / (GGXV + GGXL);
	#endif
}

float V_SmithGGXCorrelated_Anisotropic_vertex(float at, float ab, float ToV, float BoV, float ToL, float BoL, float NoV, float NoL)
{
	float lambdaV = NoL * length(float3(at * ToV, ab * BoV, NoV));
	float lambdaL = NoV * length(float3(at * ToL, ab * BoL, NoL));
	float v = 0.5 / (lambdaV + lambdaL);
	return saturate(v);
}


void ShadeVertexLighting(out half3 diffuse, out half3 specular, float3 PositionWS, float3 NormalWS, float3 ViewDirectionWS, half roughness, half metallic, half3 albedo = 1, half reflectance = 0.5, half energyCompensation = 1)
{
	half3 f0 = 0.16 * reflectance * reflectance * (1.0 - metallic) + albedo * metallic;

	diffuse = 0;
	specular = 0;

	#ifdef VERTEXLIGHT_ON
	    for (uint i = 0; i < GetAdditionalLightCount(); i++)
	    {
	        Light additionalLight = GetAdditionalLight(PositionWS, i);
	        float3 direction = additionalLight.direction;
	        half3 color = additionalLight.color;
	        half attenuation = additionalLight.distanceAttenuation*additionalLight.shadowAttenuation;

			half NoV = abs(dot(NormalWS, ViewDirectionWS)) + 1e-5f;
			half NoL = saturate(dot(NormalWS, direction));
			float3 halfVector = SafeNormalize(direction + ViewDirectionWS);
			half LoH = saturate(dot(direction, halfVector));
			half NoH = saturate(dot(NormalWS, halfVector));

			half3 lightdiffuse = max(NoL * attenuation * color, 0);

			//#if !defined(QUALITY_LOW)
			//	diffuse *= Fd_burley_vertex(roughness, NoV, NoL, LoH);
			//#endif

			#ifndef _SPECULARHIGHLIGHTS_OFF
				half clampedRoughness = max(roughness * roughness, 0.002);

				half3 F = F_Schlick_vertex(LoH, f0) * energyCompensation;
				half D = D_GGX_vertex(NoH, clampedRoughness);
				half V = V_SmithGGXCorrelated_vertex(NoV, NoL, clampedRoughness);

				specular += max(0.0, (D * V) * F) * lightdiffuse * PI * energyCompensation;
			#endif
			diffuse += lightdiffuse;
		}
	#endif
}