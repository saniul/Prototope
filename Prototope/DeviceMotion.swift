//
//  DeviceMotion.swift
//  Prototope
//
//  Created by Saniul Ahmed on 25/02/2015.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import Foundation
import CoreMotion

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

public class DeviceAttitudeObserver {
    private let motionManager: CMMotionManager = CMMotionManager()
    
    private var anchor: CMAttitude!
    
    private var sampleBuffer: Ring<DeviceAttitudeSample>
    
    public var latestSamples: [DeviceAttitudeSample] { return reverse(lazy(sampleBuffer).array) }
    
    private let relativeToAnchor: Bool
    
    public init(relativeToAnchor: Bool = true) {
        self.sampleBuffer = Ring(capacity: 10)
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
        }
    }
}

public struct RingGenerator<T> : GeneratorType {
    private let buffer: [T]
    private var idx: Int
    private var remainingCount: Int
    
    public mutating func next() -> T? {
        if remainingCount > 0 {
            let value = buffer[idx % buffer.count]
            remainingCount--
            idx++
            return value
        }
        return nil
    }
    
    private init(_ ring: Ring<T>) {
        buffer = ring.buffer
        remainingCount = ring.storedCount
        idx = (ring.count-remainingCount) % ring.capacity
    }
}


public struct Ring<T> : SequenceType {
    
    private var buffer = [T]()
    
    public private(set) var count = 0
    
    public let capacity: Int
    
    public var storedCount: Int {
        return min(count, capacity)
    }
    
    public init(capacity: Int) {
        assert(capacity > 0)
        self.capacity = capacity
    }
    
    mutating public func add(value: T) {
        if self.isFull {
            buffer[count % buffer.count] = value
        } else {
            buffer.append(value)
        }
        ++count
    }
    
    public var isEmpty: Bool {
        return count == 0
    }
    
    public var isFull: Bool {
        return count >= capacity
    }
    
    public func generate() -> RingGenerator<T> {
        return RingGenerator(self)
    }
}
