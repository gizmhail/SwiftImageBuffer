//
//  ImageBuffer.swift
//
//  Created by Sébastien POIVRE on 11/07/2016.
//  Copyright © 2016 Sébastien Poivre. All rights reserved.
//

import Cocoa

struct ImageSize{
    let width: Double
    let height: Double
}

enum ImageBufferError: Error {
    case SaveFail
}

// NSBitmapImageRep manipulation methods inspired by https://github.com/nst/BitmapCanvas

public class ImageBuffer {
  
    class Pixel {
        let x: Int
        let y: Int
        let image: ImageBuffer
        var value:ColorInfo?{
            get{
                let imageSize = Int(image.size.width)*Int(image.size.height)
                let buffer = UnsafeMutableRawPointer(image.context.cgContext.data)?.bindMemory(to: ColorSample.self, capacity: imageSize)
                let offset = image.bitmap.samplesPerPixel * ((Int(image.size.width) * Int(y) + Int(x)))
                if let buffer = buffer{
                    let r = buffer[offset]
                    let g = buffer[offset+1]
                    let b = buffer[offset+2]
                    let a = buffer[offset+3]
                    return ColorInfo(r, g, b, a)
                }
                return nil
            }
            
            set(rgba){
                let imageSize = Int(image.size.width)*Int(image.size.height)
                let buffer = UnsafeMutableRawPointer(image.context.cgContext.data)?.bindMemory(to: ColorSample.self, capacity: imageSize)
                if let buffer = buffer, let rgba = rgba{
                    let offset = image.bitmap.samplesPerPixel * ((Int(image.size.width) * Int(y) + Int(x)))
                    buffer[offset] = rgba.r
                    buffer[offset + 1] = rgba.g
                    buffer[offset + 2] = rgba.b
                    buffer[offset  + 3] = rgba.a
                }
            }
        }
        
        init?(x: Int, y: Int, image: ImageBuffer) {
            if(Int(image.size.width) > x && Int(image.size.height) > y){
                self.x = x
                self.y = y
                self.image = image
            }else{
                return nil
            }
        }
    }

    let bitmap: NSBitmapImageRep
    let context: NSGraphicsContext
    
    var size : CGSize {
        return bitmap.size
    }
    
    var pixels:[Pixel]{
        get{
            var pixels:[Pixel] = []
            var y = 0
            while y < Int(size.height){
                var x = 0
                while x < Int(size.width){
                    if let pixel = Pixel(x: x, y: y, image: self){
                        pixels.append(pixel)
                    }
                    x += 1;
                }
                y += 1
            }
            return pixels
        }
    }

    convenience init?(imageSize:ImageSize) {
        self.init(width: Int(imageSize.width), height: Int(imageSize.height))
    }
    
    public init?(width:Int, height:Int) {
        let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes:nil,
            pixelsWide:width,
            pixelsHigh:height,
            bitsPerSample:8,
            samplesPerPixel:4,
            hasAlpha:true,
            isPlanar:false,
            colorSpaceName:NSDeviceRGBColorSpace,
            bytesPerRow:width*4,
            bitsPerPixel:32)
        
        guard let bitmap = bitmapRep else{
            return nil
        }
        
        self.bitmap = bitmap
        
        guard let context = NSGraphicsContext(bitmapImageRep: self.bitmap) else{
            return nil
        }
        
        self.context = context
        NSGraphicsContext.setCurrent(self.context)
        
        // Inverts y axis and moves origin upper left (instead of lower left)
        self.context.cgContext.translateBy(x: 0, y: CGFloat(height))
        self.context.cgContext.scaleBy(x: 1.0, y: -1.0)
    }
    
    public func save(path:String) throws {
        guard let data = self.bitmap.representation(using: .PNG, properties: [:]) else {
            throw ImageBufferError.SaveFail
        }
        
        do {
            try data.write(to: URL(fileURLWithPath: path))
        } catch {
            throw ImageBufferError.SaveFail
        }        
    }
    
    static func displayImage(atPath imageFilePath: String){
        // Open the file in preview application
        NSWorkspace.shared().openFile(imageFilePath)
    }
}
