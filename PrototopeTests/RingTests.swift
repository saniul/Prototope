//
//  RingTests.swift
//  Prototope
//
//  Created by Saniul Ahmed on 15/03/2015.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import Foundation
import Prototope
import XCTest

class RingTests: XCTestCase {
    func testInitialState() {
        let ring = Ring<Int>(capacity: 5)
        XCTAssertEqual(ring.capacity, 5)
        XCTAssertTrue(ring.isEmpty)
        XCTAssertEqual(ring.count, 0)
        XCTAssertFalse(ring.isFull)
        XCTAssertEqual(lazy(ring).array, [])
    }

    func testEmptiness() {
        var ring = Ring<Int>(capacity: 3)
        XCTAssertTrue(ring.isEmpty)
        ring.add(1)
        XCTAssertFalse(ring.isEmpty)
    }
    
    func testFullness() {
        var ring = Ring<Int>(capacity: 3)
        XCTAssertFalse(ring.isFull)
        ring.add(1)
        XCTAssertFalse(ring.isFull)
        ring.add(2)
        XCTAssertFalse(ring.isFull)
        ring.add(3)
        XCTAssertTrue(ring.isFull)
    }
    
    func testRingOverwritingBehavior() {
        var ring = Ring<Int>(capacity: 3)
        XCTAssertEqual(lazy(ring).array, [])
        ring.add(1)
        XCTAssertEqual(lazy(ring).array, [1])
        ring.add(2)
        XCTAssertEqual(lazy(ring).array, [1, 2])
        ring.add(3)
        XCTAssertEqual(lazy(ring).array, [1, 2, 3])
        ring.add(4)
        XCTAssertEqual(lazy(ring).array, [2, 3, 4])
    }
    
    func testRingCounts() {
        var ring = Ring<Int>(capacity: 3)
        XCTAssertEqual(lazy(ring).array, [])
        ring.add(1)
        XCTAssertEqual(lazy(ring).array, [1])
        XCTAssertEqual(ring.count, 1)
        XCTAssertEqual(ring.storedCount, 1)
        ring.add(2)
        XCTAssertEqual(lazy(ring).array, [1, 2])
        XCTAssertEqual(ring.count, 2)
        XCTAssertEqual(ring.storedCount, 2)
        ring.add(3)
        XCTAssertEqual(lazy(ring).array, [1, 2, 3])
        XCTAssertEqual(ring.count, 3)
        XCTAssertEqual(ring.storedCount, 3)
        ring.add(4)
        XCTAssertEqual(lazy(ring).array, [2, 3, 4])
        XCTAssertEqual(ring.count, 4)
        XCTAssertEqual(ring.storedCount, 3)
        ring.add(5)
        XCTAssertEqual(lazy(ring).array, [3, 4, 5])
        XCTAssertEqual(ring.count, 5)
        XCTAssertEqual(ring.storedCount, 3)
    }
    
    func testRingValueToBeRemovedNext() {
        var ring = Ring<Int>(capacity: 3)
        
        XCTAssertNil(ring.valueToBeRemovedNext)
        ring.add(1)
        XCTAssertNil(ring.valueToBeRemovedNext)
        ring.add(2)
        XCTAssertNil(ring.valueToBeRemovedNext)
        ring.add(3)
        XCTAssertNotNil(ring.valueToBeRemovedNext)
        XCTAssertEqual(ring.valueToBeRemovedNext!, 1)
        ring.add(4)
        XCTAssertNotNil(ring.valueToBeRemovedNext)
        XCTAssertEqual(ring.valueToBeRemovedNext!, 2)
    }
    
    func testReset() {
        var ring = Ring<Int>(capacity: 3)
        
        ring.add(1)
        ring.add(2)
        ring.add(3)
        XCTAssertEqual(lazy(ring).array, [1, 2, 3])
        XCTAssertEqual(ring.count, 3)
        ring.reset()
        XCTAssertEqual(lazy(ring).array, [])
        XCTAssertEqual(ring.count, 0)
    }
}


