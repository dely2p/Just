//
//  Kernels.metal
//  RealityStone
//
//  Created by dely on 2018. 10. 19..
//  Copyright © 2018년 dely. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void pixelate(texture2d<float, access::read> inTexture [[texture(0)]],
                     texture2d<float, access::read> inTexture2 [[texture(1)]],
                     texture2d<float, access::write> outTexture [[texture(2)]],
                     uint2 gid [[thread_position_in_grid]]){
    
    const float4 colorAtPixel = inTexture.read(gid);
    const float4 colorAtPixel2 = inTexture2.read(gid);
    const int bitMask = 255;
    const int bit = 3;
    const float r = float((int(colorAtPixel.r*255) & uint8_t(bitMask << bit)) | uint8_t(colorAtPixel2.r)*255 >> (8-bit))/255;
    const float g = float((int(colorAtPixel.g*255) & uint8_t(bitMask << bit)) | uint8_t(colorAtPixel2.g)*255 >> (8-bit))/255;
    const float b = float((int(colorAtPixel.b*255) & uint8_t(bitMask << bit)) | uint8_t(colorAtPixel2.b)*255 >> (8-bit))/255;
//    const float r = float((uint8_t(colorAtPixel.r)*255 & (bitMask << bit)) | uint8_t(colorAtPixel2.r)*255 >> (8-bit))/255;
//    const float g = float((uint8_t(colorAtPixel.g)*255 & (bitMask << bit)) | uint8_t(colorAtPixel2.g)*255 >> (8-bit))/255;
//    const float b = float((uint8_t(colorAtPixel.b)*255 & (bitMask << bit)) | uint8_t(colorAtPixel2.b)*255 >> (8-bit))/255;
    const float4 outputColor = float4(r, g, b, 1.0);
    outTexture.write(outputColor, gid);
}

kernel void pixelate2(texture2d<float, access::read> inTexture [[texture(0)]],
                     texture2d<float, access::write> outTexture [[texture(1)]],
                     uint2 gid [[thread_position_in_grid]]){
    
    const float4 colorAtPixel = inTexture.read(gid);
    const int bit = 3;
    const float r = rotate(colorAtPixel.r, bit);
    const float g = rotate(colorAtPixel.g, bit);
    const float b = rotate(colorAtPixel.b, bit);
    const float4 outputColor = float4(r, g, b, 1.0);
    outTexture.write(outputColor, gid);
}
