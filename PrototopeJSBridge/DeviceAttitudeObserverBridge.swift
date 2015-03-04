//
//  DeviceAttitudeObserverBridge.swift
//  Prototope
//
//  Created by Saniul Ahmed on 27/02/2015.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc public protocol DeviceAttitudeSampleJSExport: JSExport {
    public var timestamp: TimeInterval { get }
    
    public var roll: Double { get }
    public var pitch: Double { get }
    public var yaw: Double { get }
}

@objc public protocol DeviceAttitudeObserverJSExport: JSExport {
    init?(args: NSDictionary)
    
    public var latestSamples: [DeviceAttitudeSampleBridge] { get }
    
    public func resetAnchor()
}