//
//  VMDKError.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import CLibVMDK

/// Errors produced by ``VMDKHandle`` and related helpers when libvmdk returns failure or the wrapper detects invalid use.
///
/// Every case carries a human-readable message, often including text from ``VMDKError/message(fromErrorPointer:)``
/// when the failure originated from a libvmdk call that populated `libvmdk_error_t **`.
public enum VMDKError: Error, Equatable {
    /// `libvmdk_handle_initialize` did not return success (`1`).
    case initializationFailed(String)

    /// `libvmdk_handle_open` failed (descriptor path, permissions, or format).
    case openFailed(String)

    /// Descriptor opened but `libvmdk_handle_open_extent_data_files` failed; the wrapper attempts to close the handle.
    case openExtentDataFilesFailed(String)

    /// `libvmdk_handle_read_buffer` or `libvmdk_handle_read_buffer_at_offset` failed.
    case readFailed(String)

    /// `libvmdk_handle_seek_offset` failed.
    case seekFailed(String)

    /// `libvmdk_handle_close` did not return `0`.
    case closeFailed(String)

    /// A metadata query (size, disk type, extent list, etc.) failed or returned an unexpected code.
    case metadataFailed(String)

    /// Wrapper-level state error (e.g. double open, invalid parameters) without a specific libvmdk error object.
    case invalidState(String)
}
