#!/bin/bash
set -euxo pipefail

export CROSS_COMPILE=aarch64-linux-gnu-
export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
# Tempting to add  -D__ARMEL__ to these flags but while it compiles, it SIGSEGV on use.
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export HOST="aarch64-linux-gnu"
export CMAKE_OPTIONS="-DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=arm64 -DRUN_HAVE_STD_REGEX=0 -DRUN_HAVE_POSIX_REGEX=0"

source ./build-linux.sh

mkdir -p "${ARTIFACTS_DIR}/Linux/aarch64"
cp .libs/libleveldbjni.so "${ARTIFACTS_DIR}/Linux/aarch64/"