//
//  VMDKHandle+Library.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import CLibVMDK
import Foundation

extension VMDKHandle {
    /// Build-time version string of the linked libvmdk library (e.g. `"20251220"`).
    ///
    /// Wraps `libvmdk_get_version`. If the C function returns `NULL`, this returns an empty string (no force-unwrap).
    public static var version: String {
        guard let ptr = libvmdk_get_version() else {
            return ""
        }
        return String(cString: ptr)
    }
}
