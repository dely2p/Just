//
//  RGBData.swift
//  Just
//
//  Created by dely on 2018. 5. 24..
//  Copyright © 2018년 dely. All rights reserved.
//

import Foundation

class RGBData {
    var r: CFBit
    var g: CFBit
    var b: CFBit
    var a: CFBit
    init(r: String, g: String, b: String, a: String) {
        self.r = CFBit(r)!
        self.g = CFBit(g)!
        self.b = CFBit(b)!
        self.a = CFBit(a)!
    }
    init(r: CFBit, g: CFBit, b: CFBit, a: CFBit) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}
