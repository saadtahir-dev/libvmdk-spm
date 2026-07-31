// swift-tools-version:5.9
import PackageDescription
import Foundation

let packageDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent().path

let package = Package(
    name: "libvmdk-spm",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "CLibVMDK",     targets: ["CLibVMDK"]),
        .library(name: "CLibVMDKFuse", targets: ["CLibVMDKFuse"]),
        .library(name: "LibVMDK",      targets: ["LibVMDK"]),
    ],
    targets: [
        .target(
            name: "CLibVMDK",
            path: "Sources/CLibVMDK",
            sources: ["placeholder.c"],
            publicHeadersPath: "include",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDK/libvmdk.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDK/libbfio.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDK/libcdata.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDK/libcerror.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDK/libclocale.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDK/libcnotify.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDK/libcpath.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDK/libcsplit.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDK/libcthreads.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDK/libfcache.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDK/libfdata.a",
                ]),
                .linkedLibrary("z"),
                .linkedLibrary("pthread"),
            ]
        ),
        .target(
            name: "CLibVMDKFuse",
            path: "Sources/CLibVMDKFuse",
            sources: ["placeholder.c"],
            publicHeadersPath: "include",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDKFuse/libvmdk.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDKFuse/libbfio.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDKFuse/libcdata.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDKFuse/libcerror.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDKFuse/libclocale.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDKFuse/libcnotify.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDKFuse/libcpath.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDKFuse/libcsplit.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDKFuse/libcthreads.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDKFuse/libfcache.a",
                    "-Xlinker", "\(packageDirectory)/Sources/CLibVMDKFuse/libfdata.a",
                    "-L/usr/local/lib",
                    "-lfuse",
                ]),
                .linkedLibrary("z"),
                .linkedLibrary("pthread"),
            ]
        ),
        .target(
            name: "CLibVMDKResources",
            dependencies: ["CLibVMDK"],
            path: "Sources/CLibVMDKResources",
            resources: [
                .copy("bin"),
                .copy("lib")
            ]
        ),
        .target(
            name: "LibVMDK",
            dependencies: ["CLibVMDK", "CLibVMDKResources"],
            path: "Sources/LibVMDK"
        ),
        .testTarget(
            name: "LibVMDKTests",
            dependencies: ["CLibVMDK"],
            path: "Tests/LibVMDKTests"
        ),
        .testTarget(
            name: "LibVMDKSwiftTests",
            dependencies: ["LibVMDK"],
            path: "Tests/LibVMDKSwiftTests"
        ),
    ]
)
