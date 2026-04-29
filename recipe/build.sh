#!/usr/bin/env bash

set -eux

# zip 3.0 has legacy K&R-style prototypes that conflict with modern glibc
# headers (memset/memcpy/memcmp, strchr redefinition). GCC 14+ promoted these
# to errors by default, so demote them back to warnings to keep the build
# compatible with newer toolchains.
export CFLAGS="${CFLAGS} -DLARGE_FILE_SUPPORT -DZIP64_SUPPORT -Wno-error=incompatible-pointer-types -Wno-error=implicit-function-declaration -Wno-error=builtin-declaration-mismatch"

mkdir -p bzip2

# patch in default conda-forge compiler flags
sed -i "s|^CFLAGS_NOOPT =|CFLAGS_NOOPT = $CFLAGS $CPPFLAGS |" unix/Makefile
sed -i "s|^LFLAGS1=''|LFLAGS1='$LDFLAGS'|" unix/configure

make -f unix/Makefile generic prefix="${PREFIX}" CC="${CC}" CPP="${CC_FOR_BUILD} -E" install
