//
//  VMDKExtentDescriptor.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import CLibVMDK

/// Immutable snapshot of one VMDK extent entry (type, media range, optional backing filename).
///
/// Instances are produced by ``VMDKHandle/extentDescriptor(at:)`` after the handle has been opened.
public struct VMDKExtentDescriptor: Sendable {
    /// Extent storage class (flat, sparse, VMFS, zero fill, etc.).
    public let type: VMDKExtentType

    /// Starting byte offset of this extent within the **virtual** disk media (from `libvmdk_extent_descriptor_get_range`).
    public let offset: Int64

    /// Length of this extent in bytes (from `libvmdk_extent_descriptor_get_range`).
    public let size: UInt64

    /// UTF-8 filename for this extent when the descriptor references a separate file; `nil` if libvmdk reports the name as unavailable.
    public let filename: String?
}

// MARK: - Internal construction

extension VMDKExtentDescriptor {
    /// Builds a descriptor by querying libvmdk on the given native extent pointer.
    ///
    /// - Parameter extentOpaque: Address of a valid `libvmdk_extent_descriptor_t *` (exposed as `OpaquePointer` for Swift API boundaries).
    ///
    /// - Important: Call only while the underlying descriptor object is still alive; typically used immediately after
    ///   `libvmdk_handle_get_extent_descriptor` and before `libvmdk_extent_descriptor_free`.
    internal init(extentOpaque: OpaquePointer) {
        let extentPtr = UnsafeMutableRawPointer(extentOpaque).assumingMemoryBound(to: libvmdk_extent_descriptor_t.self)

        var rawType: Int32 = 0
        var offset: off64_t = 0
        var size: size64_t = 0

        _ = libvmdk_extent_descriptor_get_type(extentPtr, &rawType, nil)
        _ = libvmdk_extent_descriptor_get_range(extentPtr, &offset, &size, nil)

        var utf8Size: size_t = 0
        let sizeResult = libvmdk_extent_descriptor_get_utf8_filename_size(extentPtr, &utf8Size, nil)

        let name: String?
        if sizeResult == 1, utf8Size > 0 {
            var buffer = [UInt8](repeating: 0, count: utf8Size)
            let getResult = buffer.withUnsafeMutableBufferPointer { buf in
                libvmdk_extent_descriptor_get_utf8_filename(extentPtr, buf.baseAddress, utf8Size, nil)
            }
            if getResult == 1 {
                name = String(decoding: buffer.prefix(while: { $0 != 0 }), as: UTF8.self)
            } else {
                name = nil
            }
        } else {
            name = nil
        }

        self.type = VMDKExtentType(rawExtentType: rawType)
        self.offset = offset
        self.size = UInt64(size)
        self.filename = name
    }
}
