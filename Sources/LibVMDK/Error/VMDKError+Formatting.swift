//
//  VMDKError+Formatting.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import CLibVMDK

// MARK: - Error text

extension VMDKError {
    /// Formats the current libvmdk error, frees it with `libvmdk_error_free`, and returns the resulting text.
    ///
    /// - Parameter errorPP: Pointer to the `libvmdk_error_t *` variable used with libvmdk APIs (`libvmdk_error_t **` in C).
    ///   When this function runs, `*errorPP` should be non-`nil` if the preceding call failed; on exit the pointed-to pointer is cleared.
    /// - Returns: A UTF-8 string from `libvmdk_error_sprint` into an internal 4096-byte buffer, or a short fallback if formatting fails.
    ///
    /// - Important: Call only when you own the error object from a failed libvmdk call; this routine **frees** the error.
    public static func message(fromErrorPointer errorPP: UnsafeMutablePointer<UnsafeMutablePointer<libvmdk_error_t>?>) -> String {
        guard let err = errorPP.pointee else {
            return "Unknown error"
        }
        defer {
            var errOpt: UnsafeMutablePointer<libvmdk_error_t>? = err
            withUnsafeMutablePointer(to: &errOpt) { ee in
                libvmdk_error_free(ee)
            }
            errorPP.pointee = nil
        }
        var buffer = [CChar](repeating: 0, count: 4096)
        let printed = libvmdk_error_sprint(err, &buffer, buffer.count)
        if printed < 0 {
            return "Unable to format libvmdk error"
        }
        return String(decoding: buffer.prefix(while: { $0 != 0 }).map { UInt8(bitPattern: $0) }, as: UTF8.self)
    }
}
