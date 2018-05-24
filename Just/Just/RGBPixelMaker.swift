//
//  RGBPixelMaker.swift
//  Just
//
//  Created by dely on 2018. 5. 24..
//  Copyright © 2018년 dely. All rights reserved.
//

import UIKit

class RGBPixelMaker {
    
    func makeBinaryPixel(image: UIImage) {
        let size = CGSize(width: 10, height: 10)
        let pixelData = image.cgImage?.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let position = CGPoint(x: 1, y: 1)
        let pixelInfo: Int = ((Int(size.width) * Int(position.y)) + Int(position.x)) * 4
        
        let r = String(Int(CGFloat(data[pixelInfo])), radix: 2)
        let g = String(Int(CGFloat(data[pixelInfo+1])), radix: 2)
        let b = String(Int(CGFloat(data[pixelInfo+2])), radix: 2)
        let a = String(Int(CGFloat(data[pixelInfo+3])), radix: 2)
        print("r: \(r)", "g: \(g)", "b: \(b)", "a: \(a)")
    }
}
