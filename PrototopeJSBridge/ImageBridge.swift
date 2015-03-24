//
//  ImageBridge.swift
//  Prototope
//
//  Created by Andy Matuschak on 2/2/15.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import Foundation
import Prototope
import JavaScriptCore

@objc public protocol ImageJSExport: JSExport {
	init?(args: NSDictionary)
    
    func toPixels() -> PixelBitmapJSExport
}

@objc public class ImageBridge: NSObject, ImageJSExport, BridgeType {
	var image: Image!

	public class func addToContext(context: JSContext) {
		context.setObject(self, forKeyedSubscript: "Image")
	}

	required public init?(args: NSDictionary) {
		if let imageName = args["name"] as! String? {
			image = Image(name: imageName)
			super.init()
		} else {
			super.init()
			return nil
		}
	}

	init(_ image: Image) {
		self.image = image
		super.init()
	}
    
    public func toPixels() -> PixelBitmapJSExport {
        let pixelBitmap = image.toPixels()
        return PixelBitmapBridge(pixelBitmap)
    }
}

@objc public protocol PixelBitmapJSExport: JSExport {
    var pixelWidth: Int { get }
    var pixelHeight: Int { get }
    
    func toImage() -> ImageJSExport
    
    func pixelAt(args: NSDictionary) -> PixelJSExport
    
    func map(args: NSDictionary)
}

@objc public class PixelBitmapBridge: NSObject, PixelBitmapJSExport, BridgeType {
    var pixelBitmap: PixelBitmap!
    
    public class func addToContext(context: JSContext) {
        context.setObject(self, forKeyedSubscript: "PixelBitmap")
    }
    
    init(_ pixelBitmap: PixelBitmap) {
        self.pixelBitmap = pixelBitmap
        super.init()
    }
    
    public var pixelWidth: Int {
        return pixelBitmap.pixelWidth
    }
    
    public var pixelHeight: Int {
        return pixelBitmap.pixelHeight
    }
    
    public func toImage() -> ImageJSExport {
        let image = pixelBitmap.toImage()
        return ImageBridge(image)
    }
    
    public func pixelAt(args: NSDictionary) -> PixelJSExport {
        let row = (args["row"] as! Int?) ?? 0
        let column = (args["column"] as! Int?) ?? 0
        let pixel = self.pixelBitmap.pixelAt(row: row, column: column)
        return PixelBridge(pixel)
    }
    
    public func map(args: NSDictionary) {
        let transformValue = (args["transform"] as! JSValue)
        // TODO: Implement this
    }
}

@objc public protocol PixelJSExport: JSExport {
    var red: Float { get set }
    var green: Float { get set }
    var blue: Float { get set }
    var alpha: Float { get set }
    
    var color: ColorJSExport { get set }
}

@objc public class PixelBridge: NSObject, PixelJSExport, BridgeType {
    var pixel: Pixel!
    
    public class func addToContext(context: JSContext) {
        context.setObject(self, forKeyedSubscript: "Pixel")
    }
    
    init(_ pixel: Pixel) {
        self.pixel = pixel
        super.init()
    }
    
    public var red: Float {
        get {
            return pixel.red
        }
        set {
            pixel.red = newValue
        }
    }
    
    public var green: Float {
        get {
            return pixel.green
        }
        set {
            pixel.green = newValue
        }
    }
    
    public var blue: Float {
        get {
            return pixel.blue
        }
        set {
            pixel.blue = newValue
        }
    }
    
    public var alpha: Float {
        get {
            return pixel.alpha
        }
        set {
            pixel.alpha = newValue
        }
    }
    
    public var color: ColorJSExport {
        get {
            return ColorBridge(pixel.color)
        }
        set {
            pixel.color = (newValue as! ColorBridge).color
        }
    }
}

