# libvmdk-spm

A Swift Package (SPM) that wraps [libvmdk](https://github.com/libyal/libvmdk) by Joachim Metz as universal static libraries for reading VMware Virtual Machine Disk (`.vmdk`) images on macOS, with bundled mount and info tools.

---

## What This Is

`libvmdk-spm` provides a type-safe Swift API for opening and reading VMDK forensic images on macOS. It wraps libvmdk behind `CLibVMDK` (C headers + static archives) and exposes `VMDKHandle`, metadata types, and bundled tool paths via `LibVMDK`.

The package ships prebuilt universal fat binaries (arm64 + x86_64) for libvmdk and all libyal dependencies — no separate library installation required.

---

## Requirements

- macOS 12.0+
- Xcode 15+
- [macFUSE](https://osxfuse.github.io/) 4.x or 5.x (required for `vmdkmount` at runtime)

---

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/saadtahir-dev/libvmdk-spm.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "LibVMDK", package: "libvmdk-spm")
        ]
    )
]
```

For local development alongside other forensic packages:

```swift
dependencies: [
    .package(path: "../libvmdk-spm")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "LibVMDK", package: "libvmdk-spm")
        ]
    )
]
```

Or add via Xcode: **File → Add Package Dependencies** → paste the repo URL.

**Products:**

| Product | Target | Use when |
|---|---|---|
| `LibVMDK` | `LibVMDK` | Swift API + bundled tools (typical) |
| `CLibVMDK` | `CLibVMDK` | C/libvmdk only, no Swift wrapper |
| `CLibVMDKFuse` | `CLibVMDKFuse` | Same static libs + macFUSE headers for custom FUSE tooling |

Or add via Xcode: **File → Add Package Dependencies** → paste the repo URL.

---

## Usage

```swift
import LibVMDK

// Get library version
print("libvmdk version: \(VMDKHandle.version)")

// Resolve bundled mount tool (requires macFUSE at runtime)
if let vmdkmount = VMDKToolLocator.vmdkmount {
    print("vmdkmount: \(vmdkmount)")
}

// Open and read a VMDK descriptor
do {
    let handle = try VMDKHandle()
    try handle.open(path: "/path/to/disk.vmdk")

    let size = try handle.mediaSize()
    print("Media size: \(size) bytes")

    let data = try handle.read(count: 512, at: 0)
    print("Read \(data.count) bytes")

    try handle.close()
} catch let error as VMDKError {
    print("Failed: \(error)")
}
```

---

## API

### `VMDKHandle`

`VMDKHandle` is a `final class` conforming to `@unchecked Sendable`. The underlying `libvmdk_handle_t` is not thread-safe — serialize access if you share one instance across threads.

`deinit` closes an open handle and frees the C object; explicit `close()` is recommended for deterministic cleanup.

| Method / Property | Description |
|---|---|
| `init() throws` | Allocates a new handle via `libvmdk_handle_initialize`. Throws `VMDKError.initializationFailed`. |
| `func open(path: String) throws` | Opens the VMDK descriptor read-only and opens extent data files. |
| `func close() throws` | Closes the handle. No-op if never opened. |
| `func read(count: Int) throws -> Data` | Reads at the current media offset (advances cursor). |
| `func read(count: Int, at offset: Int64) throws -> Data` | Reads at a specific media offset. |
| `func seek(offset: Int64, whence: Int32) throws -> Int64` | Repositions the read cursor (POSIX `lseek` semantics). |
| `func currentOffset() throws -> Int64` | Returns the current media offset. |
| `func mediaSize() throws -> UInt64` | Total virtual disk size in bytes. |
| `func diskType() throws -> VMDKDiskType` | VMware disk layout classification. |
| `func extentDescriptor(at index: Int) throws -> VMDKExtentDescriptor` | Snapshot of one extent entry. |
| `static var version: String` | Linked libvmdk version string (e.g. `"20251220"`). |

---

### `VMDKDiskType`

Swift enum mapping `LIBVMDK_DISK_TYPES` (flat, sparse, stream-optimized, VMFS variants, etc.).

| Method | Description |
|---|---|
| `init(rawDiskType: Int32)` | Maps a libvmdk disk-type integer; unknown values become `.unknown`. |

---

### `VMDKExtentDescriptor`

Immutable extent metadata: type, offset, size, and optional backing filename.

| Property | Description |
|---|---|
| `type: VMDKExtentType` | Extent storage class (flat, sparse, zero, …). |
| `offset: Int64` | Start offset within virtual media. |
| `size: UInt64` | Extent length in bytes. |
| `filename: String?` | Backing file path when applicable. |

---

### `VMDKToolLocator`

Resolves paths to bundled executables in the `CLibVMDKResources` resource bundle (`bin/`).

| Property / Method | Description |
|---|---|
| `static func path(for tool: String) -> String?` | Generic tool lookup by name. |
| `static var vmdkmount: String?` | Path to bundled `vmdkmount`. |
| `static var vmdkinfo: String?` | Path to bundled `vmdkinfo`. |

---

### `VMDKError`

```swift
public enum VMDKError: Error, Equatable {
    case initializationFailed(String)
    case openFailed(String)
    case openExtentDataFilesFailed(String)
    case readFailed(String)
    case seekFailed(String)
    case closeFailed(String)
    case metadataFailed(String)
    case invalidState(String)
}
```

---

## Supported Formats

| Format | Extension | Support |
|---|---|---|
| VMware VMDK (descriptor + extents) | `.vmdk` | Supported |
| Monolithic flat / sparse | `.vmdk` | Supported |
| Split 2 GB extent | `.vmdk` + `-s001.vmdk`, … | Supported |
| Stream-optimized | `.vmdk` | Supported |
| VMFS-hosted variants | `.vmdk` | Supported (via libvmdk) |

---

## Bundled Libraries

All dependencies are statically linked as universal fat binaries (arm64 + x86_64). The `CLibVMDK` target links eleven prebuilt archives:

| Library | Version | Purpose |
|---|---|---|
| libvmdk | 20251220 | VMDK read implementation |
| libbfio | libyal | Basic File IO |
| libcdata | libyal | Common data structures |
| libcerror | libyal | Error handling |
| libclocale | libyal | Locale support |
| libcnotify | libyal | Verbose output |
| libcpath | libyal | Path utilities |
| libcsplit | libyal | String splitting |
| libcthreads | libyal | Threading |
| libfcache | libyal | File cache |
| libfdata | libyal | File data streams |
| zlib | latest | Compression |

The following macOS system libraries are also linked:

- `libz`, `libpthread` — compression and threading

`CLibVMDKFuse` duplicates the same static libraries and adds `-L/usr/local/lib -lfuse` for macFUSE header compatibility when building FUSE-aware tooling.

---

## Bundled Tools

Prebuilt command-line tools ship in `Sources/CLibVMDKResources/bin/` and are resolved via `VMDKToolLocator`.

| Tool | Purpose | macFUSE |
|---|---|---|
| `vmdkmount` | Mount a VMDK image as a raw block device via FUSE | Required |
| `vmdkinfo` | Print VMDK metadata | No |

| Property | Value |
|---|---|
| Architectures | Universal (arm64 + x86_64) |
| FUSE linkage | System `/usr/local/lib/libfuse3.4.dylib` (macFUSE), absolute path |
| Resolution | `CLibVMDKResources` SPM resource bundle |

---

## macFUSE Compatibility

`vmdkmount` requires macFUSE to be installed and loaded on the target machine, and links against the **system-installed** `/usr/local/lib/libfuse3.4.dylib` by absolute path — it does not bundle its own copy.

An earlier build of this package tried vendoring a private copy of `libfuse3.4.dylib` into the resource bundle and re-signing it under this package's own Developer ID, to work around hardened-runtime library-validation rejecting macFUSE's Team ID. That approach doesn't work: `libfuse3.4.dylib` isn't standalone — it's one piece of a multi-component macFUSE installation, and it itself loads `MFMount.framework` (`/Library/Filesystems/macfuse.fs/Contents/Frameworks/MFMount.framework/...`), a separate component signed under macFUSE's own Team ID and tied to the user's installed macFUSE version and kernel/system extension. Resigning our copy of `libfuse3.4.dylib` didn't change that inner dependency's signature — so the same Team ID mismatch just reappeared one level deeper in the load chain.

**The actual fix**: `vmdkmount` links the system `libfuse3.4.dylib` directly (matching whatever macFUSE version the user has installed, avoiding any version skew), and the **consuming app must sign `vmdkmount` with the `com.apple.security.cs.disable-library-validation` entitlement**. This package does not sign its own binaries with this entitlement — bundling an SPM resource doesn't preserve a signature or entitlements through Xcode's normal build/archive process, so the entitlement has to be applied by whichever app embeds and (re-)signs `vmdkmount` as part of its own build (see ReconLab's `Sign Imaging Binaries` build phase for a reference implementation). Scope the entitlement to `vmdkmount` specifically, not the whole app — `vmdkinfo` doesn't touch macFUSE and doesn't need it.

This libvmdk release already ships a correct `fuse_darwin_attr` boundary layer in `vmdktools/mount_fuse.c` for macFUSE 5.x (Darwin attribute fields use `size`, `mode`, `nlink`, not the older `fa_size`/`fa_mode` names) — **no source patch is applied by this package.**

For build steps and troubleshooting, see the [swift-forensic-playbook](https://github.com/saadtahir-dev/swift-forensic-playbook). Note the playbook's `fuse_darwin_attr` patch script targets an older libvmdk release; check upstream `vmdktools/mount_fuse.h` before applying it on a fresh clone — it may already be a no-op.

---

## Building From Source

See the [swift-forensic-playbook](https://github.com/saadtahir-dev/swift-forensic-playbook) for the complete step-by-step guide covering:

- Building libvmdk and all libyal dependencies as **static-only** universal archives (`--enable-static --disable-shared`), arm64 + x86_64, `lipo`'d together
- Checking whether the target libvmdk release needs the macFUSE 5.x `fuse_darwin_attr` boundary-layer patch to `vmdktools/mount_fuse.c` (not needed as of the version currently vendored here — verify against upstream before assuming otherwise)
- Linking `vmdkmount` against the system `/usr/local/lib/libfuse3.4.dylib` (absolute path — do **not** vendor and re-sign a private copy; see macFUSE Compatibility above for why)
- Bundling `vmdkmount` and `vmdkinfo`
- Creating the SPM package structure with `CLibVMDK`, `CLibVMDKFuse`, and `LibVMDK` targets
- A note for consuming apps: sign `vmdkmount` with `com.apple.security.cs.disable-library-validation` at archive/export time, scoped to that binary only

---

## License

MIT — see [LICENSE](./LICENSE)

---

## Related

- [swift-forensic-playbook](https://github.com/saadtahir-dev/swift-forensic-playbook) — Build guides for forensic image libraries as Swift Packages
- [libyal/libvmdk](https://github.com/libyal/libvmdk) — Upstream libvmdk library
- [ImageMounter](https://github.com/saadtahir-dev/ImageMounter) — macOS forensic image mounting service (uses `VMDKToolLocator` for VMDK)
