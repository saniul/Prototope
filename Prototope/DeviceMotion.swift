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
    let roll: Double
    let pitch: Double
    let yaw: Double
    
    init(cmAttitude: CMAttitude) {
        self.roll = cmAttitude.roll
        self.pitch = cmAttitude.pitch
        self.yaw = cmAttitude.yaw
    }
}

public class DeviceAttitudeObserver {
    private let motionManager: CMMotionManager = CMMotionManager()
    
    typealias DeviceAttitudeHandler = DeviceAttitudeSample -> Void
    
    private let handler: DeviceAttitudeHandler
    
    func deviceMotionHandler(deviceMotion: CMDeviceMotion) {
        let sample = DeviceAttitudeSample(cmAttitude: deviceMotion.attitude)
        handler(sample)
    }
    
    func errorHandler(error: NSError) {
        if error.code == Int(CMErrorDeviceRequiresMovement.value) {
            motionManager.showsDeviceMovementDisplay = true
        }
    }
    
    init(handler: DeviceAttitudeHandler) {
        self.handler = handler
        
        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryCorrectedZVertical, toQueue: NSOperationQueue.mainQueue()) { (deviceMotion, error) -> Void in
            if error != nil {
                self.errorHandler(error)
            }
            
            if deviceMotion != nil {
                self.deviceMotionHandler(deviceMotion)
            }
        }
    }
}