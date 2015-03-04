//
//  Context.swift
//  Prototope
//
//  Created by Andy Matuschak on 2/3/15.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import Foundation
import JavaScriptCore
import Prototope

@objc public class WeakContextRef: NSObject, JSExport {
    
    init(context: Context) {
        self.context = context
    }
    
    public weak var context: Context?
    
    deinit {
        println("killed weak ctx")
    }
}

public class Context {
	public var exceptionHandler: (JSValue -> Void)? {
		didSet {
			context.exceptionHandler = { [exceptionHandler = self.exceptionHandler] context, value in
				exceptionHandler?(value)
				context.exception = nil
				return
			}
		}
	}

    public var consoleLogHandler: (String -> Void)? = { str in
        println(str)
    }

	private let vm = JSVirtualMachine()
	private let context: JSContext

	public init() {
		context = JSContext(virtualMachine: vm)
		addBridgedTypes()
	}
    
    public func tearDown() {
        println("tearing down Context")
        println("clearing root LayerBridge")
        Layer.root.removeAllSublayers()
        LayerBridge.root.removeAllSublayers()
        let success = self.context.globalObject.objectForKeyedSubscript("Layer").deleteProperty("root")
        println("killing Layer.root -> \(success)")
        println("clearing root Layer")
        
        for key in self.context.globalObject.toDictionary().keys.array {
            let success = self.context.globalObject.deleteProperty(key as! String)
            self.context.setObject(NSNull(), forKeyedSubscript: key as! String)
            println("\tdeleting global.\(key) -> \(success)")
        }
    }
    
    deinit {
        println("killed Context")
    }

	public func evaluateScript(script: String!) -> JSValue {
		return context.evaluateScript("\"use strict\";" + script)
	}

	private func addBridgedTypes() {
		let console = JSValue(newObjectInContext: context)
		let loggingTrampoline: @objc_block JSValue -> Void = { [weak self] value in
			self?.consoleLogHandler?(value.toString())
			return
		}
		console.setFunctionForKey("log", fn: loggingTrampoline)
		context.setObject(console, forKeyedSubscript: "console")
        
        let weakRef = WeakContextRef(context: self)
        context.setObject(weakRef, forKeyedSubscript: "weakContext")

		LayerBridge.addToContext(context)
		ColorBridge.addToContext(context)
		BorderBridge.addToContext(context)
		ShadowBridge.addToContext(context)
		ImageBridge.addToContext(context)
		PointBridge.addToContext(context)
		SizeBridge.addToContext(context)
		RectBridge.addToContext(context)
		TunableBridge.addToContext(context)
		TimingBridge.addToContext(context)
		MathBridge.addToContext(context)
		HeartbeatBridge.addToContext(context)
		SoundBridge.addToContext(context)
		TouchSampleBridge.addToContext(context)
		TouchSequenceBridge.addToContext(context)
		TapGestureBridge.addToContext(context)
		PanGestureBridge.addToContext(context)
		SampleSequenceBridge.addToContext(context)
		ContinuousGesturePhaseBridge.addToContext(context)
		RotationSampleBridge.addToContext(context)
		RotationGestureBridge.addToContext(context)
		PinchSampleBridge.addToContext(context)
		PinchGestureBridge.addToContext(context)
		AnimationCurveBridge.addToContext(context)
		VideoBridge.addToContext(context)
		VideoLayerBridge.addToContext(context)
		ParticleBridge.addToContext(context)
		ParticleEmitterBridge.addToContext(context)
		ScrollLayerBridge.addToContext(context)
        CollisionBehaviorBridge.addToContext(context)
        ActionBehaviorBridge.addToContext(context)
        CollisionBehaviorKindBridge.addToContext(context)
		TextLayerBridge.addToContext(context)
		SpeechBridge.addToContext(context)
		TextAlignmentBridge.addToContext(context)
	}
}