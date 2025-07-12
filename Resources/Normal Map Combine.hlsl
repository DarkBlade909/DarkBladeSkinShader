void CustomFunction(float3 n1, float3 n2, out float3 Out)
{
    Out = normalize(float3(n1.xy + n2.xy, n1.z));
  //Out = normalize(float3(n1.xy + n2.xy, n1.z * n2.z));

}