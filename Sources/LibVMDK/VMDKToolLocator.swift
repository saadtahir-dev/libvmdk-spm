//
//  VMDKToolLocator.swift
//  libvmdk-spm
//
//  Created by Saad Tahir on 13/05/2026.
//   -- GitHub   : https://github.com/saadtahir-dev
//   -- LinkedIn : https://www.linkedin.com/in/saadtahir-dev
//

import Foundation
import CLibVMDKResources

public enum VMDKToolLocator {

    private static let lock = NSLock()
    private static var cache: [String: String] = [:]

    public static func path(for tool: String) -> String? {
        lock.lock()
        if let cached = cache[tool] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        if let url = CLibVMDKResourcesBundle.bundle.url(
            forResource: tool,
            withExtension: nil,
            subdirectory: "bin"
        ) {
            let path = url.path

            try? FileManager.default.setAttributes(
                [.posixPermissions: 0o755],
                ofItemAtPath: path
            )

            if FileManager.default.isExecutableFile(atPath: path) {
                lock.lock()
                cache[tool] = path
                lock.unlock()

                print("[VMDKToolLocator] Cached \(tool) -> \(path)")
                return path
            }
        }

        print("[VMDKToolLocator] Tool not found in CLibVMDKResources bundle: \(tool)")
        return nil
    }

    public static var vmdkmount: String? { path(for: "vmdkmount") }
    public static var vmdkinfo: String? { path(for: "vmdkinfo") }
}
