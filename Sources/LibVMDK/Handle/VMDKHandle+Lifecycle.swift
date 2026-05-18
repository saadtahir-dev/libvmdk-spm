//
//  VMDKHandle+Lifecycle.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import CLibVMDK

/// Matches `LIBVMDK_OPEN_READ` (`0x01`) from libvmdk; read-only access for ``VMDKHandle/open(path:)``.
private let libvmdkOpenRead: Int32 = 1

extension VMDKHandle {
    /// Opens a VMDK descriptor and its extent data files for reading.
    ///
    /// Equivalent to calling `libvmdk_handle_open` with `LIBVMDK_OPEN_READ`, then `libvmdk_handle_open_extent_data_files`.
    /// Extent files are resolved relative to the descriptor unless you use lower-level C APIs to set paths first.
    ///
    /// - Parameter path: Filesystem path to the primary VMDK descriptor (often a `.vmdk` file).
    /// - Throws:
    ///   - ``VMDKError/invalidState(_:)`` if the handle is already open or was not initialized.
    ///   - ``VMDKError/openFailed(_:)`` if the descriptor cannot be opened.
    ///   - ``VMDKError/openExtentDataFilesFailed(_:)`` if extent backing files cannot be opened (the handle is closed again in this case).
    public func open(path: String) throws {
        guard !isOpen else {
            throw VMDKError.invalidState("Handle is already open")
        }
        guard let h = handlePtr else {
            throw VMDKError.invalidState("Handle is not initialized")
        }
        try Self.withLibVMDKError { errPP in
            let openResult = path.withCString { cPath in
                libvmdk_handle_open(h, cPath, libvmdkOpenRead, errPP)
            }
            guard openResult == 1 else {
                throw VMDKError.openFailed(VMDKError.message(fromErrorPointer: errPP))
            }
            let extentResult = libvmdk_handle_open_extent_data_files(h, errPP)
            guard extentResult == 1 else {
                _ = libvmdk_handle_close(h, nil)
                throw VMDKError.openExtentDataFilesFailed(VMDKError.message(fromErrorPointer: errPP))
            }
            self.isOpen = true
        }
    }

    /// Closes the VMDK and releases open file resources.
    ///
    /// Wraps `libvmdk_handle_close`. If the handle was never opened, this returns immediately without calling into libvmdk.
    ///
    /// - Throws: ``VMDKError/closeFailed(_:)`` if the library reports a close error.
    public func close() throws {
        guard isOpen, let h = handlePtr else { return }
        try Self.withLibVMDKError { errPP in
            let result = libvmdk_handle_close(h, errPP)
            guard result == 0 else {
                throw VMDKError.closeFailed(VMDKError.message(fromErrorPointer: errPP))
            }
            self.isOpen = false
        }
    }
}
