//
//  ColorInfo.swift
//
//  Created by Sébastien POIVRE on 13/07/2016.
//  Copyright © 2016 Sébastien Poivre. All rights reserved.
//

import Foundation

typealias ColorSample = UInt8

struct ColorInfo {
    
    let r: ColorSample
    let g: ColorSample
    let b: ColorSample
    let a: ColorSample
    
    static let maxSample:ColorSample = 255
    
    init(r: ColorSample, g: ColorSample, b: ColorSample, a: ColorSample = maxSample){
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    init(_ r: ColorSample, _ g: ColorSample, _ b: ColorSample,_ a: ColorSample = maxSample){
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    init(white intensity: ColorSample){
        self.r = intensity
        self.g = intensity
        self.b = intensity
        self.a = ColorInfo.maxSample
    }
    
    func dimed(intensity: Double) -> ColorInfo{
        let f = { (i:ColorSample) -> (ColorSample) in ColorSample(Double(i)*intensity)}
        return ColorInfo(
            f(r),
            f(g),
            f(b),
            a
        )
    }

    
}

extension ColorInfo:Equatable{
    public static func ==(c1: ColorInfo, c2: ColorInfo) -> Bool {
        return c1.r == c2.r && c1.g == c2.g && c1.b == c2.b && c1.a == c2.a
    }
}

// MARK: Color  blending
extension ColorInfo {
    func blended(with otherColor: ColorInfo, ratio: Double) -> ColorInfo {
        let r = self.r.blendColorValue(with: otherColor.r, ratio: ratio)
        let g = self.g.blendColorValue(with: otherColor.g, ratio: ratio)
        let b = self.b.blendColorValue(with: otherColor.b, ratio: ratio)
        let a = self.a.blendAlphaValue(with: otherColor.a, ratio: ratio)
        return ColorInfo(r, g, b, a)
    }
}

extension ColorSample {
    // See http://stackoverflow.com/a/29321264/5844074
    func blendColorValue(with otherSample: ColorSample, ratio: Double) -> ColorSample{
        let value1 = Double(self)
        let value2 = Double(otherSample)
        let blendedValue = sqrt( (1-ratio)*value1*value1 + ratio*value2*value2 )
        return ColorSample(blendedValue)
    }

    func blendAlphaValue(with otherSample: ColorSample, ratio: Double) -> ColorSample{
        let value1 = Double(self)
        let value2 = Double(otherSample)
        let blendedValue = sqrt( (1-ratio)*value1*value1 + ratio*value2*value2 )
        return ColorSample(blendedValue)
    }
}

