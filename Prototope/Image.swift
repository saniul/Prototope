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

/** A representation of an image bitmap that allows pixel data access */
public struct PixelBitmap : MutableCollectionType {
    typealias Index = Int
    
    public var pixelWidth: Int { return width }
    public var pixelHeight: Int { return height }
    
    private let width: Int
    private let height: Int
    
    public let startIndex: Int = 0
    public var endIndex: Int { return height * width }
    
    private let scale: Double
    
    private var data: UnsafeMutablePointer<Pixel>
    
    private let dataDestroyer: PixelDataDestroyer
    
    init(image: Image) {
        scale = Double(image.uiImage.scale)
        width = Int(image.size.width * scale)
        height = Int(image.size.height * scale)
        
        data = UnsafeMutablePointer<Pixel>.alloc(width * height)
        dataDestroyer = PixelDataDestroyer(data: data, width: width, height: height)
        
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        let bytesPerRow = width * 4
        
        let context = CGBitmapContextCreate(data, width, height, 8, bytesPerRow, colorSpace, bitmapInfo)
        
        let cgImageSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: cgImageSize), image.uiImage.CGImage)
    }
    
    public subscript (position: Int) -> Pixel {
        get {
            return data[position]
        }
        set {
            data[position] = newValue
        }
    }
    
    /** Returns the pixel data at a given position. */
    public func pixelAt(#position: Int) -> Pixel? {
        if position < height * width {
            return self[position]
        } else {
            return nil
        }
    }
    
    /** Sets the pixel data at a given position. */
    public mutating func setPixelAt(#position: Int, value: Pixel) {
        self[position] = value
    }
    
    public subscript (#row: Int, #column: Int) -> Pixel {
        get {
            let idx = indexOf(row: row, column: column)
            return self[idx]
        }
        set {
            let idx = indexOf(row: row, column: column)
            self[idx] = newValue
        }
    }
    
    /** Returns the pixel data at a given row and column. */
    public func pixelAt(#row: Int, column: Int) -> Pixel? {
        if row < pixelHeight && column < pixelWidth {
            return self[row: row, column: column]
        } else {
            return nil
        }
    }
    
    /** Sets the pixel data at a given row and column. */
    public mutating func setPixelAt(#row: Int, column: Int, value: Pixel) {
        self[row: row, column: column] = value
    }
    
    public func generate() -> IndexingGenerator<PixelBitmap> {
        return IndexingGenerator(self)
    }
    
    /** Returns the Image representation of the PixelBitmap. */
    public func toImage() -> Image {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(data, width, height, 8, width * 4, colorSpace, bitmapInfo)
        let cgImage = CGBitmapContextCreateImage(context)
        
        let image = UIImage(CGImage: cgImage, scale: CGFloat(scale), orientation: .Up)!
        
        return Image(image)
    }
    
    /** Constructs a new PixelBitmap by applying the transform on each pixel the original. */
    public func map(transform: Pixel -> Pixel) -> PixelBitmap {
        var newBitmap = self
        for idx in startIndex..<endIndex {
            newBitmap[idx] = transform(self[idx])
        }
        
        return newBitmap
    }

    /** Constructs a new PixelBitmap by applying the transform on each pixel the original. */
    public func map(transform: (position: Int, Pixel) -> Pixel) -> PixelBitmap {
        var newBitmap = self
        for idx in startIndex..<endIndex {
            newBitmap[idx] = transform(position: idx, self[idx])
        }
        
        return newBitmap
    }
    
    /** Constructs a new PixelBitmap by applying the transform on each pixel the original. */
    public func map(transform: (row: Int, column: Int, Pixel) -> Pixel) -> PixelBitmap {
        var newBitmap = self
        for idx in startIndex..<endIndex {
            let row = idx % width
            let column = idx - (row * width)
            newBitmap[idx] = transform(row: row, column:column, self[idx])
        }
        
        return newBitmap
    }
    
    private func indexOf(#row: Int, column: Int) -> Int {
        return row * width + column
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
    private var redRaw: UInt8
    private var greenRaw: UInt8
    private var blueRaw: UInt8
    private var alphaRaw: UInt8
    
    public var red: Float {
        get { return Float(redRaw)/255 }
        set { self.redRaw = UInt8(min(1, max(0, newValue))*255) }
    }
    
    public var green: Float {
        get { return Float(greenRaw)/255 }
        set { self.greenRaw = UInt8(min(1, max(0, newValue))*255) }
    }
    
    public var blue: Float {
        get { return Float(blueRaw)/255 }
        set { self.blueRaw = UInt8(min(1, max(0, newValue))*255) }
    }
    
    public var alpha: Float {
        get { return Float(alphaRaw)/255 }
        set { self.alphaRaw = UInt8(min(1, max(0, newValue))*255) }
    }
    
    public var color: Color {
        get { return Color(red: red, green: green, blue: blue, alpha: alpha) }
        set {
            let (r, g, b, a) = newValue.getRGBAValues()
            self.red = Float(r)
            self.green = Float(g)
            self.blue = Float(b)
            self.alpha = Float(a)
        }
    }
}

