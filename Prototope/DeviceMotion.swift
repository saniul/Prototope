//
//  DeviceMotion.swift
//  Prototope
//
//  Created by Saniul Ahmed on 25/02/2015.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import Foundation
import CoreMotion

/** Represents a sample of the device's attitude at a point in time */
public struct DeviceAttitudeSample {
    public let timestamp: TimeInterval
    
    public let roll: Double
    public let pitch: Double
    public let yaw: Double
    
    init(timestamp: TimeInterval, cmAttitude: CMAttitude) {
        self.timestamp = timestamp
        self.roll = cmAttitude.roll
        self.pitch = cmAttitude.pitch
        self.yaw = cmAttitude.yaw
    }
}

/** When initialized, this class starts observing the device's attitude. It reports
    the last N samples (`capacity` parameter in the constructor) through the `latestSamples`
    property.

    The `relativeToAnchor` parameter lets you specify that the values reported should
    be relative to a reference frame (the position of the device when the observer is initialized).
    You can reset the anchor using the `resetAnchor` method and the observer will use the next
    detected value as the reference frame.
*/
public class DeviceAttitudeObserver {
    private let motionManager: CMMotionManager = CMMotionManager()
    
    private var anchor: CMAttitude!
    
    private var sampleBuffer: Ring<DeviceAttitudeSample>
    
    /** Most recent N attitude samples observed, reported in the order from most recent to least recent. */
    public var latestSamples: [DeviceAttitudeSample] { return reverse(lazy(sampleBuffer).array) }
    
    private let relativeToAnchor: Bool
    
    /** The constructed observer will report the most recent `capacity` samples 
    through the `latestSamples` property.
    The `relativeToAnchor` parameter lets you specify that the values reported should
    be relative to a reference frame (the position of the device when the observer is initialized). */
    public init(relativeToAnchor: Bool = true, capacity: Int = 10) {
        self.sampleBuffer = Ring(capacity: capacity)
        self.relativeToAnchor = relativeToAnchor
        
        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryCorrectedZVertical,
            toQueue: NSOperationQueue.mainQueue()) { [weak self] (deviceMotion, error) -> Void in
                if error != nil {
                    self?.errorHandler(error)
                }
                
                if deviceMotion != nil {
                    self?.updateWithDeviceMotion(deviceMotion)
                }
        }
    }
    
    /** You can reset the anchor using the `resetAnchor` method and the observer will use the next
    detected value as the reference frame. */
    public func resetAnchor() {
        self.anchor = nil
    }
    
    func updateAnchor() {
        self.anchor = self.motionManager.deviceMotion.attitude
    }
    
    func updateWithDeviceMotion(deviceMotion: CMDeviceMotion) {
        if anchor == nil {
            updateAnchor()
        }
        
        let translated = deviceMotion.attitude
        if relativeToAnchor {
            translated.multiplyByInverseOfAttitude(anchor)
        }
        
        let sample = DeviceAttitudeSample(timestamp: deviceMotion.timestamp, cmAttitude: translated)
        sampleBuffer.add(sample)
    }
    
    func errorHandler(error: NSError) {
        if error.code == Int(CMErrorDeviceRequiresMovement.value) {
            motionManager.showsDeviceMovementDisplay = true
        } else {
            Environment.currentEnvironment?.exceptionHandler("DeviceAttitudeObserver Error: \(error.description)")
        }
    }
}
