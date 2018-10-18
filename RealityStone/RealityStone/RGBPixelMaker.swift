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
        for y in 0..<Int(size.height) {
            for x in 0..<Int(size.width) {
                let position = CGPoint(x: x, y: y)
                let pixelInfo: Int = ((Int(x) * Int(position.y)) + Int(position.x)) * 4
                
                let r = UInt8(CGFloat(data[pixelInfo]))
                let g = UInt8(CGFloat(data[pixelInfo+1]))
                let b = UInt8(CGFloat(data[pixelInfo+2]))
                let a = UInt8(CGFloat(data[pixelInfo+3]))
                imageOfRGBData.append(RGBData.init(r: r, g: g, b: b, a: a))
            }
        }
        return imageOfRGBData
    }
    
    func printByFormat(_ value: UInt8) -> String {
        var binaryValue = String(value, radix: 2)
        return binaryValue.pad()
    }
    
    func printImagefirstByte(_ rgbData: [RGBData], _ index: Int) {
        print("\(index) pixel r: \(printByFormat(rgbData[index].r)), g: \(printByFormat(rgbData[index].g)), b: \(printByFormat(rgbData[index].b)), a: \(printByFormat(rgbData[index].a))")
    }
    
    func makebitMixing(imageA: [RGBData], imageB: [RGBData], bit: Int) -> [RGBData] {
        // 두 이미지 중 작은 값을 기준으로
        var imageOfMixing: [RGBData] = []
        let bitMask: UInt8 = 255
        
        // 사진 사이즈 조정하기
        // 사진 사이즈를 지정해두고 그 사이즈에 맞게 가로 세로 이미지를 조정(늘리기)하는 게 좋을까
        // 아님 비율만 줄이고 빈 공간을 흰색이나 검은색으로 채우는 게 좋을까
        
        let image = imageA.count < imageB.count ? imageA : imageB
        for index in 0..<image.count {
            let resultR = imageA[index].r & bitMask << bit | imageB[index].r >> (8 - bit)
            let resultG = imageA[index].g & bitMask << bit | imageB[index].g >> (8 - bit)
            let resultB = imageA[index].b & bitMask << bit | imageB[index].b >> (8 - bit)
            let resultA = imageA[index].a
            imageOfMixing.append(RGBData.init(r: resultR, g: resultG, b: resultB, a: resultA))
            if index < 1075 {
                printImagefirstByte(imageA, index)
                printImagefirstByte(imageB, index)
                printImagefirstByte(imageOfMixing, index)
            }
        }
        return imageOfMixing
    }
    
    func makeMixingImage(rgbData: [RGBData], coverImage: UIImage) -> UIImage {
        let cgImage: CGImage?
        let width = Int(size.width)
        let height = Int(size.height)
        let bitsPerComponent = 8 // UInt8
        let bytePerPixel = 4 // 픽셀당 바이트?? RBGA
        let bytesPerRow = bytePerPixel * width // 픽셀당 바이트 * 가로 = 가로 전체 바이트(846 * 4 = 3384)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var pixelsOfMixingImage = makeRGBAPixel(rgbData: rgbData) //697136
        
        guard let bitmapContext = CGContext(data: &pixelsOfMixingImage,
                                            width: width,
                                            height: height,
                                            bitsPerComponent: Int(bitsPerComponent),
                                            bytesPerRow: Int(bytesPerRow),
                                            space: colorSpace,
                                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return coverImage
        }
        
        guard let image = bitmapContext.makeImage() else {
            return coverImage
        }
        cgImage = image
        return UIImage(cgImage: cgImage!)
    }
    
    func makeRGBAPixel(rgbData: [RGBData]) -> [UInt8] {
        var pixelsOfMixingImage: [UInt8] = []
        for data in rgbData {
            pixelsOfMixingImage.append(data.r)
            pixelsOfMixingImage.append(data.g)
            pixelsOfMixingImage.append(data.b)
            pixelsOfMixingImage.append(data.a)
        }
        return pixelsOfMixingImage
    }
}

extension String {
    mutating func pad() -> String {
        let size = 8 - self.count
        var padding = ""
        for _ in 0..<size {
            padding += "0"
        }
        self = padding + self
        return self
    }
}
