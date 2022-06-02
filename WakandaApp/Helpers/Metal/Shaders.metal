#include <metal_stdlib>
using namespace metal;

struct SingleInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
};

vertex SingleInputVertexIO oneInputVertex(device packed_float2 *position [[buffer(0)]],
                                          device packed_float2 *texturecoord [[buffer(1)]],
                                          uint vid [[vertex_id]])
{
    SingleInputVertexIO outputVertices;
    outputVertices.position = float4(position[vid], 0, 1.0);
    outputVertices.textureCoordinate = texturecoord[vid];
    return outputVertices;
}



// MARK: passthroughFragment
fragment half4 passthroughFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                   texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    return color;
}



// MARK: luminanceFragment
// Luminance Constants
constant half3 luminanceWeighting = half3(0.2125, 0.7154, 0.0721);

fragment half4 luminanceFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                   texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half luminance = dot(color.rgb, luminanceWeighting);

    return half4(half3(luminance), color.a);
}



// MARK: VHSFragment
// https://www.shadertoy.com/view/Ms3XWH
constant float range = 0.05;
constant float noiseQuality = 250.0;
constant float noiseIntensity = 0.0088;
constant float offsetIntensity = 0.02;
constant float colorOffsetIntensity = 1.3;

float rand(float2 co)
{
    return fract(sin(dot(co.xy, float2(12.9898,78.233))) * 43758.5453);
}

float verticalBar(float pos, float uvY, float offset)
{
    float edge0 = (pos - range);
    float edge1 = (pos + range);

    float x = smoothstep(edge0, pos, uvY) * offset;
    x -= smoothstep(pos, edge1, uvY) * offset;
    return x;
}

float mod(float x, float y)
{
    return x - y * floor(x/y);
}

fragment half4 VHSFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                   device float *time [[buffer(2)]],
                                   texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;

    // float2 uv = fragCoord.xy / iResolution.xy;    
    float2 uv = fragmentInput.textureCoordinate;
    
    float iTime = *time;
    
    for (float i = 0.0; i < 0.71; i += 0.1313)
    {
        float d = mod(iTime * i, 1.7);
        float o = sin(1.0 - tan(iTime * 0.24 * i));
        o *= offsetIntensity;
        uv.x += verticalBar(d, uv.y, o);
    }
    
    float uvY = uv.y;
    uvY *= noiseQuality;
    uvY = float(int(uvY)) * (1.0 / noiseQuality);
    float noise = rand(float2(iTime * 0.00001, uvY));
    uv.x += noise * noiseIntensity;

    float2 offsetR = float2(0.006 * sin(iTime), 0.0) * colorOffsetIntensity;
    float2 offsetG = float2(0.0073 * (cos(iTime * 0.97)), 0.0) * colorOffsetIntensity;
    
//    float r = texture(iChannel0, uv + offsetR).r;
//    float g = texture(iChannel0, uv + offsetG).g;
//    float b = texture(iChannel0, uv).b;

    float r = inputTexture.sample(quadSampler, uv + offsetR).r;
    float g = inputTexture.sample(quadSampler, uv + offsetG).g;
    float b = inputTexture.sample(quadSampler, uv).b;
    
    return half4(r, g, b, 1.0);
}



// MARK: VHSFragment
// https://www.shadertoy.com/view/ls3Xzf
float rand(float time) {
    return fract(sin(time)*1e4);
}

fragment half4 glitchFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                   device float *time [[buffer(2)]],
                                   texture2d<half> inputTexture [[texture(0)]])
{
    constexpr sampler quadSampler;
    
    float2 uv = fragmentInput.textureCoordinate;
    
    float2 uvR = uv;
    float2 uvB = uv;
    
    float iTime = *time;
    
    uvR.x = uv.x * 1.0 - rand(iTime) * 0.02 * 0.8;
    uvB.y = uv.y * 1.0 + rand(iTime) * 0.02 * 0.8;
    
    if(uv.y < rand(iTime) && uv.y > rand(iTime) -0.1 && sin(iTime) < 0.0)
    {
        uv.x = (uv + 0.02 * rand(iTime)).x;
    }
    
    half4 c;
    c.r = inputTexture.sample(quadSampler, uvR).r;
    c.g = inputTexture.sample(quadSampler, uv).g;
    c.b = inputTexture.sample(quadSampler, uvB).b;
    
    float scanline = sin(uv.y * 800.0 * rand(iTime))/30.0;
    c *= 1.0 - scanline;
    
    //vignette
    float vegDist = length((0.5, 0.5) - uv);
    c *= 1.0 - vegDist * 0.6;
    
    return c;
}

