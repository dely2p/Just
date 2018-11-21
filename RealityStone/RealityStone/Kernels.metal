//
//  Kernels.metal
//  RealityStone
//
//  Created by dely on 2018. 10. 19..
//  Copyright © 2018년 dely. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// encode
uint mixOfImagesByBit(uint imageA, uint imageB){
    uint bOfImageA = (imageA >> 16) & 0xff;
    uint gOfImageA = (imageA >> 8) & 0xff;
    uint rOfImageA = (imageA) & 0xff;

    uint bOfImageB = (uint(imageB) >> 16) & 0xff;
    uint gOfImageB = (uint(imageB) >> 8) & 0xff;
    uint rOfImageB = (imageB) & 0xff;

    uint bit = 3;

//    uint newR = insert_bits(rOfImageA, uint(0x00), 0, bit) & 0xff;
//    uint newG = insert_bits(gOfImageA, uint(0x00), 0, bit) & 0xff;
//    uint newB = insert_bits(bOfImageA, uint(0x00), 0, bit) & 0xff;
    
//    uint newR = insert_bits(rOfImageA, (extract_bits(rOfImageB, 8-bit, bit)), 0, bit) & 0xff;
//    uint newG = (insert_bits(gOfImageA, (extract_bits(gOfImageB, 8-bit, bit)), 0, bit) + 0b1) & 0xff;
//    uint newB = (insert_bits(bOfImageA, (extract_bits(bOfImageB, 8-bit, bit)), 0, bit) + 0b11) & 0xff;
    
    uint newR = (rOfImageA & (0xff << bit)) | (rOfImageB >> (8-bit));
    uint newG = (gOfImageA & (0xff << bit)) | ((gOfImageB >> (8-bit+2)));
    uint newB = (bOfImageA & (0xff << bit)) | ((bOfImageB >> (8-bit+2)));

    return ((uint8_t(0xff) << 24) | (uint8_t(newB) << 16) | (uint8_t(newG) << 8) | (uint8_t(newR)));
}

float4 makeSteganoBit(float4 imageA, float4 imageB){
    // from float to uint(binary) 변환
    uint imageAOfBinary = pack_float_to_unorm4x8(imageA);
    uint imageBOfBinary = pack_float_to_unorm4x8(imageB);
    
    // bit mix
    uint mixImage = mixOfImagesByBit(imageAOfBinary, imageBOfBinary);
    
    // float 변환
    return unpack_unorm4x8_to_float(mixImage);
}

kernel void pixelate(texture2d<float, access::read> inTexture [[texture(0)]],
                     texture2d<float, access::read> inTexture2 [[texture(1)]],
                     texture2d<float, access::write> outTexture [[texture(2)]],
                     uint2 gid [[thread_position_in_grid]]){
    
    const float4 imageA = inTexture.read(gid);
    const float4 imageB = inTexture2.read(gid);
    
    const float4 mixRGBA = makeSteganoBit(imageA, imageB);

    const float4 outputColor = float4(mixRGBA);
    outTexture.write(outputColor, gid);
}

// decode
uint extractColorBit(uint image){
    uint bOfImage = (image >> 16) & 0xff;
    uint gOfImage = (image >> 8) & 0xff;
    uint rOfImage = (image) & 0xff;
    uint bit = 3;
    
//    uint newB = extract_bits(bOfImage, 0, bit) << (8-bit);
//    uint newG = extract_bits(gOfImage, 0, bit) << (8-bit);
//    uint newR = extract_bits(rOfImage, 0, bit) << (8-bit);

    uint newR = (rOfImage & (0xff >> (8-bit))) << (8-bit);
    uint newG = (gOfImage & (0xff >> (8-bit))) << (8-bit);
    uint newB = (bOfImage & (0xff >> (8-bit))) << (8-bit);
    
    return ((0xff << 24) | (newB << 16) | (newG << 8) | (newR));
}

float4 makeDivBit(float4 mixImage){
    uint imageOfBinary = pack_float_to_unorm4x8(mixImage);
    
    uint extractImage = extractColorBit(imageOfBinary);
    
    return unpack_unorm4x8_to_float(extractImage);
}

kernel void pixelate2(texture2d<float, access::read> inTexture [[texture(0)]],
                     texture2d<float, access::write> outTexture [[texture(1)]],
                     uint2 gid [[thread_position_in_grid]]){
    
    const float4 mixImage = inTexture.read(gid);
    
    const float4 outputColor = makeDivBit(mixImage);
    outTexture.write(outputColor, gid);
}
