//
//  VMDKHandleTests.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import XCTest
import LibVMDK

final class VMDKHandleTests: XCTestCase {
    func testVersion() {
        XCTAssertFalse(VMDKHandle.version.isEmpty)
    }

    func testInitialize() throws {
        _ = try VMDKHandle()
    }

    func testInitializeProducesIndependentHandles() throws {
        let a = try VMDKHandle()
        let b = try VMDKHandle()
        XCTAssertNotIdentical(a, b)
    }

    func testCloseWhenNeverOpenedDoesNotThrow() throws {
        let h = try VMDKHandle()
        try h.close()
    }

    func testDiskTypeEnumCoversKnownRawValues() {
        XCTAssertEqual(VMDKDiskType(rawDiskType: 0), .undefined)
        XCTAssertEqual(VMDKDiskType(rawDiskType: 16), .vmfsSparseThin)
        XCTAssertEqual(VMDKDiskType(rawDiskType: 99), .unknown)
    }

    func testExtentTypeEnumCoversKnownRawValues() {
        XCTAssertEqual(VMDKExtentType(rawExtentType: 1), .flat)
        XCTAssertEqual(VMDKExtentType(rawExtentType: 7), .zero)
        XCTAssertEqual(VMDKExtentType(rawExtentType: 0), .unknown)
    }
}
