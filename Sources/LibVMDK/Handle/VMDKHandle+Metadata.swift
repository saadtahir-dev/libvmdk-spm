//
//  VMDKHandle+Metadata.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import CLibVMDK

extension VMDKHandle {
    /// Total size of the virtual disk media in bytes.
    ///
    /// Wraps `libvmdk_handle_get_media_size`. Requires a successfully opened handle (descriptor and extents).
    ///
    /// - Throws:
    ///   - ``VMDKError/invalidState(_:)`` if the handle is not initialized.
    ///   - ``VMDKError/metadataFailed(_:)`` if libvmdk cannot return the size.
    public func mediaSize() throws -> UInt64 {
        guard let h = handlePtr else {
            throw VMDKError.invalidState("Handle is not initialized")
        }
        var size: size64_t = 0
        try Self.withLibVMDKError { errPP in
            let result = libvmdk_handle_get_media_size(h, &size, errPP)
            guard result == 1 else {
                throw VMDKError.metadataFailed(VMDKError.message(fromErrorPointer: errPP))
            }
        }
        return UInt64(size)
    }

    /// High-level VMware disk layout classification from the descriptor.
    ///
    /// Wraps `libvmdk_handle_get_disk_type` and maps the raw integer to ``VMDKDiskType``.
    ///
    /// - Throws:
    ///   - ``VMDKError/invalidState(_:)`` if the handle is not initialized.
    ///   - ``VMDKError/metadataFailed(_:)`` if the value cannot be read.
    public func diskType() throws -> VMDKDiskType {
        guard let h = handlePtr else {
            throw VMDKError.invalidState("Handle is not initialized")
        }
        var raw: Int32 = 0
        try Self.withLibVMDKError { errPP in
            let result = libvmdk_handle_get_disk_type(h, &raw, errPP)
            guard result == 1 else {
                throw VMDKError.metadataFailed(VMDKError.message(fromErrorPointer: errPP))
            }
        }
        return VMDKDiskType(rawDiskType: raw)
    }

    /// Content ID (CID) of this disk image.
    ///
    /// Wraps `libvmdk_handle_get_content_identifier`. Used by VMware to track parent/child relationships in linked chains.
    ///
    /// - Throws:
    ///   - ``VMDKError/invalidState(_:)`` if the handle is not initialized.
    ///   - ``VMDKError/metadataFailed(_:)`` if libvmdk cannot read the identifier.
    public func contentIdentifier() throws -> UInt32 {
        guard let h = handlePtr else {
            throw VMDKError.invalidState("Handle is not initialized")
        }
        var value: UInt32 = 0
        try Self.withLibVMDKError { errPP in
            let result = libvmdk_handle_get_content_identifier(h, &value, errPP)
            guard result == 1 else {
                throw VMDKError.metadataFailed(VMDKError.message(fromErrorPointer: errPP))
            }
        }
        return value
    }

    /// Parent disk content identifier when this image is a delta/child; otherwise `nil`.
    ///
    /// Wraps `libvmdk_handle_get_parent_content_identifier`. A return value of `0` from the C API means “not available”
    /// and is surfaced as Swift `nil`, distinct from a successful read of the literal value `0` when the API returns `1`.
    ///
    /// - Throws:
    ///   - ``VMDKError/invalidState(_:)`` if the handle is not initialized.
    ///   - ``VMDKError/metadataFailed(_:)`` on unexpected libvmdk failure (`-1`).
    public func parentContentIdentifier() throws -> UInt32? {
        guard let h = handlePtr else {
            throw VMDKError.invalidState("Handle is not initialized")
        }
        var value: UInt32 = 0
        let apiResult = try Self.withLibVMDKError { errPP in
            let result = libvmdk_handle_get_parent_content_identifier(h, &value, errPP)
            guard result >= 0 else {
                throw VMDKError.metadataFailed(VMDKError.message(fromErrorPointer: errPP))
            }
            return result
        }
        if apiResult == 0 { return nil }
        return value
    }

    /// UTF-8 parent filename from the descriptor when present (linked clone / parent path metadata).
    ///
    /// Uses `libvmdk_handle_get_utf8_parent_filename_size` then `libvmdk_handle_get_utf8_parent_filename`.
    /// If the size call returns `0`, there is no parent filename and this method returns `nil`.
    ///
    /// - Throws:
    ///   - ``VMDKError/invalidState(_:)`` if the handle is not initialized.
    ///   - ``VMDKError/metadataFailed(_:)`` if size or content retrieval fails with `-1`, or the string buffer call does not return `1`.
    public func parentFilename() throws -> String? {
        guard let h = handlePtr else {
            throw VMDKError.invalidState("Handle is not initialized")
        }
        var utf8Size: size_t = 0
        let sizeResult = try Self.withLibVMDKError { errPP in
            let r = libvmdk_handle_get_utf8_parent_filename_size(h, &utf8Size, errPP)
            guard r >= 0 else {
                throw VMDKError.metadataFailed(VMDKError.message(fromErrorPointer: errPP))
            }
            return r
        }
        if sizeResult == 0 { return nil }
        var buffer = [UInt8](repeating: 0, count: utf8Size)
        try Self.withLibVMDKError { errPP in
            let getResult = buffer.withUnsafeMutableBufferPointer { buf in
                libvmdk_handle_get_utf8_parent_filename(h, buf.baseAddress, utf8Size, errPP)
            }
            guard getResult == 1 else {
                throw VMDKError.metadataFailed(VMDKError.message(fromErrorPointer: errPP))
            }
        }
        return String(decoding: buffer.prefix(while: { $0 != 0 }), as: UTF8.self)
    }

    /// Number of extent records described by the VMDK descriptor.
    ///
    /// Wraps `libvmdk_handle_get_number_of_extents`. Valid extent indices for ``extentDescriptor(at:)`` are `0 ..< extentCount()`.
    ///
    /// - Throws:
    ///   - ``VMDKError/invalidState(_:)`` if the handle is not initialized.
    ///   - ``VMDKError/metadataFailed(_:)`` if libvmdk cannot read the count.
    public func extentCount() throws -> Int {
        guard let h = handlePtr else {
            throw VMDKError.invalidState("Handle is not initialized")
        }
        var count: Int32 = 0
        try Self.withLibVMDKError { errPP in
            let result = libvmdk_handle_get_number_of_extents(h, &count, errPP)
            guard result == 1 else {
                throw VMDKError.metadataFailed(VMDKError.message(fromErrorPointer: errPP))
            }
        }
        return Int(count)
    }

    /// Snapshot of one extent’s type, byte range, and backing filename (if any) at the time of the call.
    ///
    /// Wraps `libvmdk_handle_get_extent_descriptor`, copies fields into a Swift ``VMDKExtentDescriptor``, then calls
    /// `libvmdk_extent_descriptor_free` on the library-allocated object.
    ///
    /// - Parameter index: Zero-based extent index; must be in range `0 ..< extentCount()`.
    /// - Returns: A value type holding extent metadata safe to use after the function returns.
    /// - Throws:
    ///   - ``VMDKError/invalidState(_:)`` if the handle is not initialized.
    ///   - ``VMDKError/metadataFailed(_:)`` if the extent cannot be retrieved or the library returns no pointer.
    public func extentDescriptor(at index: Int) throws -> VMDKExtentDescriptor {
        guard let h = handlePtr else {
            throw VMDKError.invalidState("Handle is not initialized")
        }
        var extentOut: UnsafeMutablePointer<libvmdk_extent_descriptor_t>? = nil
        try Self.withLibVMDKError { errPP in
            let result = withUnsafeMutablePointer(to: &extentOut) { extPP in
                libvmdk_handle_get_extent_descriptor(h, Int32(index), extPP, errPP)
            }
            guard result == 1 else {
                throw VMDKError.metadataFailed(VMDKError.message(fromErrorPointer: errPP))
            }
        }
        guard let extentCell = extentOut else {
            throw VMDKError.metadataFailed("Missing extent descriptor from libvmdk")
        }
        let descriptor = VMDKExtentDescriptor(extentOpaque: OpaquePointer(UnsafeMutableRawPointer(extentCell)))
        Self.withLibVMDKError { errPP in
            _ = withUnsafeMutablePointer(to: &extentOut) { extPP in
                libvmdk_extent_descriptor_free(extPP, errPP)
            }
        }
        return descriptor
    }
}
