//
//  VMDKDiskType.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import CLibVMDK

/// Virtual-disk layout classification from libvmdk (`LIBVMDK_DISK_TYPES`).
///
/// Raw integer values match the C enum (approximately `0` … `16`). Values outside that range map to ``unknown``.
public enum VMDKDiskType: Int32, Sendable {
    /// `LIBVMDK_DISK_TYPE_UNDEFINED`
    case undefined = 0
    /// `LIBVMDK_DISK_TYPE_FLAT_2GB_EXTENT`
    case flat2GBExtent = 1
    /// `LIBVMDK_DISK_TYPE_SPARSE_2GB_EXTENT`
    case sparse2GBExtent = 2
    /// `LIBVMDK_DISK_TYPE_CUSTOM`
    case custom = 3
    /// `LIBVMDK_DISK_TYPE_DEVICE`
    case device = 4
    /// `LIBVMDK_DISK_TYPE_DEVICE_PARITIONED` (spelling preserved from VMware/libvmdk)
    case devicePartitioned = 5
    /// `LIBVMDK_DISK_TYPE_MONOLITHIC_FLAT`
    case monolithicFlat = 6
    /// `LIBVMDK_DISK_TYPE_MONOLITHIC_SPARSE`
    case monolithicSparse = 7
    /// `LIBVMDK_DISK_TYPE_STREAM_OPTIMIZED`
    case streamOptimized = 8
    /// `LIBVMDK_DISK_TYPE_VMFS_FLAT`
    case vmfsFlat = 9
    /// `LIBVMDK_DISK_TYPE_VMFS_FLAT_PRE_ALLOCATED`
    case vmfsFlatPreAllocated = 10
    /// `LIBVMDK_DISK_TYPE_VMFS_FLAT_ZEROED`
    case vmfsFlatZeroed = 11
    /// `LIBVMDK_DISK_TYPE_VMFS_RAW`
    case vmfsRaw = 12
    /// `LIBVMDK_DISK_TYPE_VMFS_RDM`
    case vmfsRdm = 13
    /// `LIBVMDK_DISK_TYPE_VMFS_RDMP`
    case vmfsRdmp = 14
    /// `LIBVMDK_DISK_TYPE_VMFS_SPARSE`
    case vmfsSparse = 15
    /// `LIBVMDK_DISK_TYPE_VMFS_SPARSE_THIN`
    case vmfsSparseThin = 16
    /// Reserved for integers not recognized as a known disk type.
    case unknown = -1
}

// MARK: - Mapping from libvmdk

extension VMDKDiskType {
    /// Creates a case from the integer returned by `libvmdk_handle_get_disk_type`.
    ///
    /// - Parameter rawDiskType: The `int` written by libvmdk into the disk-type out-parameter.
    public init(rawDiskType: Int32) {
        self = Self(rawValue: rawDiskType) ?? .unknown
    }
}
