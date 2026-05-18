#ifndef VMDK_FUSE_SHIM_H
#define VMDK_FUSE_SHIM_H

#include <stdint.h>
#include <stddef.h>
#include "libvmdk.h"

#define _DARWIN_USE_64_BIT_INODE 1
#define FUSE_USE_VERSION 26
#include <fuse/fuse.h>

#endif
