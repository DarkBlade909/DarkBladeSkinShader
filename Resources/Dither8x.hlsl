inline float DitherFunction( int x, int y )
{
	const float dither[ 64 ] = {
		 1, 49, 13, 61,  4, 52, 16, 64,
		33, 17, 45, 29, 36, 20, 48, 32,
		 9, 57,  5, 53, 12, 60,  8, 56,
		41, 25, 37, 21, 44, 28, 40, 24,
		 3, 51, 15, 63,  2, 50, 14, 62,
		35, 19, 47, 31, 34, 18, 46, 30,
		11, 59,  7, 55, 10, 58,  6, 54,
		43, 27, 39, 23, 42, 26, 38, 22};
	int r = y * 8 + x;
	return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
}

void Dither8x(float2 ScreenPosition, float4 PositionCSRaw, float4 input, out float4 Out)
{
	float4 screenPos = float4(ScreenPosition.xy*PositionCSRaw.w,PositionCSRaw.zw);
	float4 screenPosNorm = screenPos/screenPos.w;
	//screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? screenPosNorm.z : screenPosNorm.z * 0.5 + 0.5;
	//float2 clipScreen1 = screenPosNorm.xy * _ScreenParams.xy;
	float2 clipScreen1 = screenPosNorm.xy * _ScreenParams.xy;
	float dither1 = DitherFunction( fmod(clipScreen1.x, 8), fmod(clipScreen1.y, 8) );
	dither1 = step( dither1, input );
	Out = dither1;
}

