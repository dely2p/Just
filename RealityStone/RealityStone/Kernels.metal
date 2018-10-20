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
    const int bit = 1;
    const float r = mix(colorAtPixel2.r, colorAtPixel.r, bit);
    const float g = mix(colorAtPixel2.g, colorAtPixel.g, bit);
    const float b = mix(colorAtPixel2.b, colorAtPixel.b, bit);
    const float4 outputColor = float4(r, g, b, 1.0);
    outTexture.write(outputColor, gid);
}

