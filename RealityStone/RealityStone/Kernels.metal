//
//  Kernels.metal
//  RealityStone
//
//  Created by dely on 2018. 10. 19..
//  Copyright © 2018년 dely. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

uint3 floatToBinary(float4 image) {
    uint r = uint(image.r*255);
    uint g = uint(image.g*255);
    uint b = uint(image.b*255);
    return uint3(r, g, b);
}
float binaryToFloat(uint color) {
    return float(float(color)/255);
}

uint mixColorBit(uint colorOfA, uint colorOfB, uint bit){
    uint secureBit = extract_bits(colorOfB & 0xff, uint(8-bit), uint(bit));
    return insert_bits(colorOfA, secureBit, uint(0), uint(bit));
}

float3 makeSteganoBit(float4 imageA, float4 imageB, uint bit){
    // binary 변환
    uint3 imageAOfBinary = floatToBinary(imageA);
    uint3 imageBOfBinary = floatToBinary(imageB);
    
    // bit mix
    uint r = mixColorBit(imageAOfBinary.r, imageBOfBinary.r, bit);
    uint g = mixColorBit(imageAOfBinary.g, imageBOfBinary.g, bit);
    uint b = mixColorBit(imageAOfBinary.b, imageBOfBinary.b, bit);
    
    // float 변환
    return float3(binaryToFloat(r), binaryToFloat(g), binaryToFloat(b));
}

uint extractColorBit(uint color, uint bit){
    uint secureBit = extract_bits(color, uint(0), uint(bit));
    return insert_bits(uint(0), secureBit, uint(8-bit), uint(bit));
//    return rotate(color, 8-bit);
}

float3 makeDivBit(float4 image, uint bit){
    // binary 변환
    uint3 imageOfBinary = floatToBinary(image);
    
    // extract image
    uint r = extractColorBit(imageOfBinary.r, bit);
    uint g = extractColorBit(imageOfBinary.g, bit);
    uint b = extractColorBit(imageOfBinary.b, bit);
    
    // float 변환
    return float3(binaryToFloat(r), binaryToFloat(g), binaryToFloat(b));
}

kernel void pixelate(texture2d<float, access::read> inTexture [[texture(0)]],
                     texture2d<float, access::read> inTexture2 [[texture(1)]],
                     texture2d<float, access::write> outTexture [[texture(2)]],
                     uint2 gid [[thread_position_in_grid]]){
    
    const float4 imageA = inTexture.read(gid);
    const float4 imageB = inTexture2.read(gid);
    const uint bit = 1;
    
    float3 mixRGB = makeSteganoBit(imageA, imageB, bit);
//    float3 mixRGB = float3(imageB.r, imageB.g, imageB.b);

    const float4 outputColor = float4(float3(mixRGB), 1.0);
    outTexture.write(outputColor, gid);
}

kernel void pixelate2(texture2d<float, access::read> inTexture [[texture(0)]],
                     texture2d<float, access::write> outTexture [[texture(1)]],
                     uint2 gid [[thread_position_in_grid]]){
    
    const float4 image = inTexture.read(gid);
    const int bit = 4;
    
    float3 extractRGB = makeDivBit(image, bit);
    
//    const float r = extractRGB.r;
//    const float g = extractRGB.g;
//    const float b = extractRGB.b;
    
    const float4 outputColor = float4(float3(extractRGB), 1.0);
    outTexture.write(outputColor, gid);
}
