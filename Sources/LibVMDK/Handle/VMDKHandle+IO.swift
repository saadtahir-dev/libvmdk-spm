//
//  VMDKHandle+IO.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import CLibVMDK
import Darwin
import Foundation

extension VMDKHandle {
    /// Reads up to `count` bytes from the **current** media offset.
    ///
    /// Wraps `libvmdk_handle_read_buffer`. The file offset advances by the number of bytes successfully read.
    ///
    /// - Parameter count: Maximum bytes to read; `0` yields empty `Data`.
    /// - Returns: A `Data` buffer trimmed to the actual byte count returned by libvmdk (may be shorter than `count` at end-of-media).
    /// - Throws:
    ///   - ``VMDKError/invalidState(_:)`` if `count` is negative or the handle is not initialized.
    ///   - ``VMDKError/readFailed(_:)`` if the library returns an error.
    public func read(count: Int) throws -> Data {
        guard count >= 0 else {
            throw VMDKError.invalidState("Read count must not be negative")
        }
        if count == 0 { return Data() }
        guard let h = handlePtr else {
            throw VMDKError.invalidState("Handle is not initialized")
        }
        var buffer = [UInt8](repeating: 0, count: count)
        let byteCount = buffer.count
        let readCount: ssize_t = try Self.withLibVMDKError { errPP in
            let r = buffer.withUnsafeMutableBytes { raw in
                libvmdk_handle_read_buffer(
                    h,
                    raw.baseAddress,
                    byteCount,
                    errPP
                )
            }
            guard r >= 0 else {
                throw VMDKError.readFailed(VMDKError.message(fromErrorPointer: errPP))
            }
            return r
        }
        buffer.removeSubrange(Int(readCount)..<buffer.count)
        return Data(buffer)
    }

    /// Reads up to `count` bytes starting at the given **media** `offset`.
    ///
    /// Wraps `libvmdk_handle_read_buffer_at_offset`. Does not require you to ``seek(offset:whence:)`` first; the current
    /// handle offset may or may not change depending on libvmdk behavior—use ``currentOffset()`` if you need the cursor position.
    ///
    /// - Parameters:
    ///   - count: Maximum bytes to read; `0` yields empty `Data`.
    ///   - offset: Zero-based byte offset into the virtual disk media.
    /// - Returns: Data trimmed to the number of bytes read.
    /// - Throws:
    ///   - ``VMDKError/invalidState(_:)`` if `count` is negative or the handle is not initialized.
    ///   - ``VMDKError/readFailed(_:)`` on libvmdk error.
    public func read(count: Int, at offset: Int64) throws -> Data {
        guard count >= 0 else {
            throw VMDKError.invalidState("Read count must not be negative")
        }
        if count == 0 { return Data() }
        guard let h = handlePtr else {
            throw VMDKError.invalidState("Handle is not initialized")
        }
        var buffer = [UInt8](repeating: 0, count: count)
        let byteCount = buffer.count
        let readCount: ssize_t = try Self.withLibVMDKError { errPP in
            let r = buffer.withUnsafeMutableBytes { raw in
                libvmdk_handle_read_buffer_at_offset(
                    h,
                    raw.baseAddress,
                    byteCount,
                    offset,
                    errPP
                )
            }
            guard r >= 0 else {
                throw VMDKError.readFailed(VMDKError.message(fromErrorPointer: errPP))
            }
            return r
        }
        buffer.removeSubrange(Int(readCount)..<buffer.count)
        return Data(buffer)
    }

    /// Repositions the read/write cursor for subsequent ``read(count:)`` calls.
    ///
    /// Wraps `libvmdk_handle_seek_offset`. The `whence` argument follows the same semantics as POSIX `lseek` (e.g. `SEEK_SET`, `SEEK_CUR`, `SEEK_END`).
    ///
    /// - Parameters:
    ///   - offset: Byte offset (interpretation depends on `whence`).
    ///   - whence: Seek origin; defaults to `SEEK_SET` (absolute position from start of media).
    /// - Returns: The new absolute media offset after a successful seek.
    /// - Throws:
    ///   - ``VMDKError/invalidState(_:)`` if the handle is not initialized.
    ///   - ``VMDKError/seekFailed(_:)`` if libvmdk reports failure (including invalid combinations of `offset` and `whence`).
    public func seek(offset: Int64, whence: Int32 = SEEK_SET) throws -> Int64 {
        guard let h = handlePtr else {
            throw VMDKError.invalidState("Handle is not initialized")
        }
        let result: off64_t = try Self.withLibVMDKError { errPP in
            let r = libvmdk_handle_seek_offset(h, offset, whence, errPP)
            guard r >= 0 else {
                throw VMDKError.seekFailed(VMDKError.message(fromErrorPointer: errPP))
            }
            return r
        }
        return Int64(result)
    }

    /// Returns the current media offset used for ``read(count:)``.
    ///
    /// Wraps `libvmdk_handle_get_offset`.
    ///
    /// - Throws:
    ///   - ``VMDKError/invalidState(_:)`` if the handle is not initialized.
    ///   - ``VMDKError/metadataFailed(_:)`` if libvmdk cannot read the offset.
    public func currentOffset() throws -> Int64 {
        guard let h = handlePtr else {
            throw VMDKError.invalidState("Handle is not initialized")
        }
        var offset: off64_t = 0
        try Self.withLibVMDKError { errPP in
            let result = libvmdk_handle_get_offset(h, &offset, errPP)
            guard result == 1 else {
                throw VMDKError.metadataFailed(VMDKError.message(fromErrorPointer: errPP))
            }
        }
        return Int64(offset)
    }
}
