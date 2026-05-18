//
//  BasicTests.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import XCTest
import CLibVMDK

final class BasicTests: XCTestCase {
    func testVersion() {
        let version = libvmdk_get_version()
        XCTAssertNotNil(version)
        print("libvmdk version: \(String(cString: version!))")
    }
}
