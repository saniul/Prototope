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
    
    func testRingBehavior() {
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
}


