//
//  VMDKExtentType.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import CLibVMDK

/// Per-extent storage kind from libvmdk (`LIBVMDK_EXTENT_TYPES`).
///
/// Known raw values are `1` … `7`. Any other value maps to ``unknown`` (`-1`).
public enum VMDKExtentType: Int32, Sendable {
    /// `LIBVMDK_EXTENT_TYPE_FLAT`
    case flat = 1
    /// `LIBVMDK_EXTENT_TYPE_SPARSE`
    case sparse = 2
    /// `LIBVMDK_EXTENT_TYPE_VMFS_FLAT`
    case vmfsFlat = 3
    /// `LIBVMDK_EXTENT_TYPE_VMFS_SPARSE`
    case vmfsSparse = 4
    /// `LIBVMDK_EXTENT_TYPE_VMFS_RAW`
    case vmfsRaw = 5
    /// `LIBVMDK_EXTENT_TYPE_VMFS_RDM`
    case vmfsRdm = 6
    /// `LIBVMDK_EXTENT_TYPE_ZERO`
    case zero = 7
    /// Unrecognized or invalid raw extent type.
    case unknown = -1
}

// MARK: - Mapping from libvmdk

extension VMDKExtentType {
    /// Creates a case from the integer returned by `libvmdk_extent_descriptor_get_type`.
    ///
    /// - Parameter rawExtentType: The `int` written by libvmdk into the extent-type out-parameter.
    public init(rawExtentType: Int32) {
        self = Self(rawValue: rawExtentType) ?? .unknown
    }
}
