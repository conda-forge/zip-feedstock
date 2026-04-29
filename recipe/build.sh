#!/usr/bin/env bash

set -eux

# zip 3.0 is from 2008 and has many issues with modern toolchains:
#  * K&R-style function definitions (fileio.c memset/memcpy/memcmp when ZMEM
#    is set) that conflict with glibc prototypes.
#  * unix/configure probes for libc functions by compiling tiny programs
#    without the corresponding headers. Under GCC 14+, implicit function
#    declarations are errors by default, so every probe fails and configure
#    activates legacy fallbacks (-DZMEM, -DNO_STRCHR, ...), which in turn
#    produce the conflicting definitions that actually break the build.
#
# Demoting the relevant GCC 14+ errors back to warnings both lets the
# configure probes succeed (so the legacy fallbacks stay disabled) and keeps
# the real compile lenient enough for zip 3.0's old C sources.
LEGACY_C_FLAGS="-Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=incompatible-pointer-types -Wno-error=int-conversion -Wno-error=builtin-declaration-mismatch"
export CC="${CC} ${LEGACY_C_FLAGS}"
export CFLAGS="${CFLAGS} -DLARGE_FILE_SUPPORT -DZIP64_SUPPORT"

mkdir -p bzip2

# patch in default conda-forge compiler flags
sed -i "s|^CFLAGS_NOOPT =|CFLAGS_NOOPT = $CFLAGS $CPPFLAGS |" unix/Makefile
sed -i "s|^LFLAGS1=''|LFLAGS1='$LDFLAGS'|" unix/configure

make -f unix/Makefile generic prefix="${PREFIX}" CC="${CC}" CPP="${CC_FOR_BUILD} -E" install
