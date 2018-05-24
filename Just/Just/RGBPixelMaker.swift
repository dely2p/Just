//
//  RGBPixelMaker.swift
//  Just
//
//  Created by dely on 2018. 5. 24..
//  Copyright © 2018년 dely. All rights reserved.
//

import UIKit

class RGBPixelMaker {
    var size: CGSize = CGSize(width: 0, height: 0)
    func makeBinaryPixel(image: UIImage) -> [RGBData] {
        var imageOfRGBData: [RGBData] = []
        size = CGSize(width: image.size.width, height: image.size.height)
        let pixelData = image.cgImage?.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        // from image to pixel 
        for x in 0..<Int(size.width) {
            for y in 0..<Int(size.height) {
                let position = CGPoint(x: x, y: y)
                let pixelInfo: Int = ((Int(x) * Int(position.y)) + Int(position.x)) * 4
                
                let r = String(Int(CGFloat(data[pixelInfo])), radix: 2).padding(toLength: 8, withPad: "0", startingAt: 0)
                let g = String(Int(CGFloat(data[pixelInfo+1])), radix: 2).padding(toLength: 8, withPad: "0", startingAt: 0)
                let b = String(Int(CGFloat(data[pixelInfo+2])), radix: 2).padding(toLength: 8, withPad: "0", startingAt: 0)
                let a = String(Int(CGFloat(data[pixelInfo+3])), radix: 2).padding(toLength: 8, withPad: "0", startingAt: 0)
                imageOfRGBData.append(RGBData.init(r: r, g: g, b: b, a: a))
                if x == 0 && y == 0 {
                    print("r: \(r), g: \(g), b: \(b), a: \(a)")
                }
            }
        }
        return imageOfRGBData
    }
    
    func makebitMixing(imageA: [RGBData], imageB: [RGBData], bit: Int) -> [RGBData] {
        // 두 이미지 중 작은 값을 기준으로
        var imageOfMixing: [RGBData] = []
        let bitMask: CFBit = 11111111
        for index in 0..<imageA.count {
            let shiftBitMask = bitMask << bit
            let imageAMasked = imageA[index].r & shiftBitMask
            let imageBShifted = imageB[index].r >> (8 - bit)
            
            let tmp = imageA[index].r & bitMask << bit | imageB[index].r >> (8 - bit)
            let resultR = CFBit(imageA[index].r & bitMask << bit | imageB[index].r >> (8 - bit))
            let resultG = CFBit(imageA[index].g & bitMask << bit | imageB[index].g >> (8 - bit))
            let resultB = CFBit(imageA[index].b & bitMask << bit | imageB[index].b >> (8 - bit))
            let resultA = CFBit(imageA[index].a)
                imageOfMixing.append(RGBData.init(r: resultR, g: resultG, b: resultB, a: resultA))
            if index == 0 {
                print("shiftBitMask: \(shiftBitMask), imageAMasked: \(imageAMasked), imageBShifted: \(imageBShifted)")
                print("tmp: \(tmp), r: \(resultR), g: \(resultG), b: \(resultB), a: \(resultA)")
            }
        }
        return imageOfMixing
    }
    
    func makeMixingImage(data: [RGBData]) -> UIImage {
        let image: UIImage!
        let elmentLength: Int = 32
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let providerRef: CGDataProvider? = CGDataProvider(data: NSData(bytes: data, length: data.count * elmentLength))
        let render: CGColorRenderingIntent = CGColorRenderingIntent.defaultIntent
        image = UIImage(cgImage: CGImage(width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: Int(size.width) * elmentLength, space: rgbColorSpace, bitmapInfo: bitmapInfo, provider: providerRef!, decode: nil, shouldInterpolate: true, intent: render)!)
        return image
    }
}
