//
//  VMDKHandle.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import CLibVMDK

/// Swift wrapper around a libvmdk disk handle (`libvmdk_handle_t *`).
///
/// Create a handle with ``init()``, call ``open(path:)`` on a descriptor path, then read or query metadata.
/// The underlying C object is not thread-safe; serialize access from multiple threads if you share one instance.
///
/// - Important: Always call ``close()`` when you are done, or rely on ``deinit`` to close and free resources.
public final class VMDKHandle: @unchecked Sendable {
    /// Pointer returned by `libvmdk_handle_initialize`; passed to every libvmdk handle API until `libvmdk_handle_free`.
    ///
    /// Stored as `internal` (not `private`) so ``VMDKHandle`` API can be organized in separate files using `extension VMDKHandle`
    /// while still accessing the same underlying C handle.
    var handlePtr: UnsafeMutablePointer<libvmdk_handle_t>?

    /// `true` after ``open(path:)`` succeeds and until ``close()`` succeeds.
    ///
    /// Used to avoid double-close, to skip close when never opened, and to satisfy ``deinit`` cleanup ordering.
    var isOpen = false

    /// Allocates a new libvmdk handle object.
    ///
    /// This calls `libvmdk_handle_initialize`. The handle is not associated with any file until you call ``open(path:)``.
    ///
    /// - Throws: ``VMDKError/initializationFailed(_:)`` if the library cannot allocate internal state.
    public init() throws {
        var out: UnsafeMutablePointer<libvmdk_handle_t>? = nil
        try Self.withLibVMDKError { errPP in
            let result = withUnsafeMutablePointer(to: &out) { outPP in
                libvmdk_handle_initialize(outPP, errPP)
            }
            guard result == 1 else {
                throw VMDKError.initializationFailed(VMDKError.message(fromErrorPointer: errPP))
            }
        }
        self.handlePtr = out
    }

    deinit {
        if isOpen {
            try? close()
        }
        Self.withLibVMDKError { errPP in
            _ = withUnsafeMutablePointer(to: &self.handlePtr) { hPP in
                libvmdk_handle_free(hPP, errPP)
            }
        }
    }

    /// Binds a fresh `libvmdk_error_t *` variable to `nil` and passes `&` that variable to `body` as the libvmdk `**error` argument.
    ///
    /// - Parameter body: Closure that performs one or more libvmdk calls using the supplied error double-pointer.
    /// - Returns: The value returned from `body`.
    /// - Throws: Rethrows any error thrown by `body`.
    static func withLibVMDKError<R>(
        _ body: (UnsafeMutablePointer<UnsafeMutablePointer<libvmdk_error_t>?>) throws -> R
    ) rethrows -> R {
        var error: UnsafeMutablePointer<libvmdk_error_t>?
        return try withUnsafeMutablePointer(to: &error) { errPP in
            try body(errPP)
        }
    }
}
