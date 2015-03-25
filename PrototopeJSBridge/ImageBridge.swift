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
    
    func pixelAt(args: NSDictionary) -> PixelJSExport?
    func setPixelAt(args: NSDictionary)
    
    func map(args: JSValue) -> PixelBitmapJSExport
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
    
    public func pixelAt(args: NSDictionary) -> PixelJSExport? {
        var pixel: Pixel?
        
        if let position = (args["position"] as! Int?) {
            pixel = self.pixelBitmap.pixelAt(position: position)
        } else if let row = (args["row"] as! Int?), let column = (args["column"] as! Int?) {
            pixel = self.pixelBitmap.pixelAt(row: row, column: column)
        } else {
            Environment.currentEnvironment?.exceptionHandler("Invalid parameters passed into Pixel.pixelAt")
        }
        
        if let pixel = pixel {
            return PixelBridge(pixel)
        } else {
            return nil
        }
    }
    
    public func setPixelAt(args: NSDictionary) {
        if let position = (args["position"] as! Int?),
            let value = (args["value"] as! PixelBridge?) {
                self.pixelBitmap.setPixelAt(position: position, value: value.pixel)
        } else if let row = (args["row"] as! Int?),
            let column = (args["column"] as! Int?),
            let value = (args["value"] as! PixelBridge?) {
                self.pixelBitmap.setPixelAt(row: row, column: column, value: value.pixel)
        } else {
            Environment.currentEnvironment?.exceptionHandler("Invalid parameters passed into Pixel.setPixelAt")
        }
        
    }
    
    public func map(args: JSValue) -> PixelBitmapJSExport {
        let transformValue = args.objectForKeyedSubscript("transform")
        let numberOfArguments = transformValue.objectForKeyedSubscript("length").toInt32()
        
        let result: PixelBitmap
        
        func safeTryCallingTransformFunction(transformValue: JSValue, withArgs args: [AnyObject], fallback fallbackBridgedPixel: PixelBridge) -> PixelBridge! {
            if let bridgedOutput = (transformValue.callWithArguments(args).toObject() as? PixelBridge) {
                return bridgedOutput
            } else {
                Environment.currentEnvironment?.exceptionHandler("PixelBridge's map transform function didn't return a transformed pixel")
                // Crashing here for now
                return nil
            }
        }
        
        switch numberOfArguments {
        case 1:
            result = pixelBitmap.map { (input: Pixel) -> Pixel in
                let bridgedInput = PixelBridge(input)
                let bridgedOutput = safeTryCallingTransformFunction(transformValue, withArgs: [bridgedInput], fallback: bridgedInput)
                return bridgedOutput.pixel
            }
        case 2:
            result = pixelBitmap.map { (position:Int, input: Pixel) -> Pixel in
                let bridgedInput = PixelBridge(input)
                let bridgedOutput = safeTryCallingTransformFunction(transformValue, withArgs: [position, bridgedInput], fallback: bridgedInput)
                return bridgedOutput.pixel
            }
        case 3:
            result = pixelBitmap.map { (row: Int, column: Int, input: Pixel) -> Pixel in
                let bridgedInput = PixelBridge(input)
                let bridgedOutput = safeTryCallingTransformFunction(transformValue, withArgs: [row, column, bridgedInput], fallback: bridgedInput)
                return bridgedOutput.pixel
            }
        default:
            Environment.currentEnvironment?.exceptionHandler("PixelBitmap's map called with an invalid transform parameter")
            result = self.pixelBitmap
        }
        
        return PixelBitmapBridge(result)
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
            pixel.color = (newValue as JSExport as! ColorBridge).color
        }
    }
}

