//
//  Image.swift
//  Prototope
//
//  Created by Andy Matuschak on 10/16/14.
//  Copyright (c) 2014 Khan Academy. All rights reserved.
//

import UIKit

/** A simple abstraction for a bitmap image. */
public struct Image {
	/** The size of the image, in points. */
	public var size: Size {
		return Size(uiImage.size)
	}

	public var name: String!

	var uiImage: UIImage

	/** Loads a named image from the assets built into the app. */
	public init!(name: String) {
		if let image = Environment.currentEnvironment!.imageProvider(name) {
			uiImage = image
			self.name = name
		} else {
			fatalError("Image named \(name) not found")
			return nil
		}
	}

	/** Constructs an Image from a UIImage. */
	init(_ image: UIImage) {
		uiImage = image
	}
    
    public func toPixels() -> PixelBitmap {
        return PixelBitmap(image: self)
    }
}

public struct PixelBitmap : MutableCollectionType {
    typealias Index = Int
    
    var data: UnsafeMutablePointer<Pixel>
    let width: Int
    let height: Int
    
    public let startIndex: Int = 0
    
    public var endIndex: Int { return height * width }
    
    private let dataDestroyer: PixelDataDestroyer
    
    init(image: Image) {
        width = Int(image.size.width)
        height = Int(image.size.height)
        
        data = UnsafeMutablePointer<Pixel>.alloc(width*height)
        dataDestroyer = PixelDataDestroyer(data: data, width: width, height: height)
        
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        let bytesPerRow = width * 4
        
        let context = CGBitmapContextCreate(data, width, height, 8, bytesPerRow, colorSpace, bitmapInfo)
        
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: image.uiImage.size), image.uiImage.CGImage)
    }
    
    public subscript (position: Int) -> Pixel {
        get { return data[position] }
        set { data[position] = newValue }
    }
    
    public func pixelAt(row: Int, column: Int) -> Pixel {
        let idx = row * width + column
        return self[idx]
    }
    
    public func generate() -> IndexingGenerator<PixelBitmap> {
        return IndexingGenerator(self)
    }
    
    public func toImage() -> Image {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(data, width, height, 8, width * 4, colorSpace, bitmapInfo)
        let cgImage = CGBitmapContextCreateImage(context)
        
        return Image(UIImage(CGImage: cgImage)!)
    }
    
    public func transform(transform: Pixel -> Pixel) -> PixelBitmap {
        var newBitmap = self
        for idx in startIndex..<endIndex {
            newBitmap[idx] = transform(self[idx])
        }
        
        return newBitmap
    }
    
    public func transform(transform: (position: Int, Pixel) -> Pixel) -> PixelBitmap {
        var newBitmap = self
        for idx in startIndex..<endIndex {
            newBitmap[idx] = transform(position: idx, self[idx])
        }
        
        return newBitmap
    }
    
    public func transform(transform: (row: Int, column: Int, Pixel) -> Pixel) -> PixelBitmap {
        var newBitmap = self
        for idx in startIndex..<endIndex {
            let row = idx % width
            let column = idx - (row * width)
            newBitmap[idx] = transform(row: row, column:column, self[idx])
        }
        
        return newBitmap
    }
    
    private class PixelDataDestroyer {
        let pixelDataToCleanUp: UnsafeMutablePointer<Pixel>
        let width: Int
        let height: Int
        
        init(data: UnsafeMutablePointer<Pixel>, width: Int, height: Int) {
            self.pixelDataToCleanUp = data
            self.width = width
            self.height = height
        }
        
        deinit {
            pixelDataToCleanUp.dealloc(width*height)
        }
    }
}


/** A representation of a single pixel in an RGBA bitmap image. */
public struct Pixel {
    public var red: UInt8
    public var green: UInt8
    public var blue: UInt8
    public var alpha: UInt8
    
    public var color: Color {
        get { return Color(red: Double(red/255), green: Double(green/255), blue: Double(blue/255), alpha: Double(alpha/255)) }
        set {
            let (r, g, b, a) = newValue.getRGBAValues()
            self.red = UInt8(r*255)
            self.green = UInt8(g*255)
            self.blue = UInt8(b*255)
            self.alpha = UInt8(a*255)
        }
    }
}

