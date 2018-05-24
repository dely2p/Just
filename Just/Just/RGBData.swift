//
//  RGBData.swift
//  Just
//
//  Created by dely on 2018. 5. 24..
//  Copyright © 2018년 dely. All rights reserved.
//

import Foundation

class RGBData {
    var r: Int8
    var g: Int8
    var b: Int8
    init(r: String, g: String, b: String) {
        self.r = Int8(r)!
        self.g = Int8(g)!
        self.b = Int8(b)!
    }
}
