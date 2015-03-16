//
//  Ring.swift
//  Prototope
//
//  Created by Saniul Ahmed on 15/03/2015.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import Foundation

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
        count++
    }
    
    public var valueToBeRemovedNext: T? {
        if isFull {
            let index = (count-storedCount) % capacity
            return buffer[index]
        }
        return nil
    }
    
    mutating public func reset() {
        count = 0
        buffer = []
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

