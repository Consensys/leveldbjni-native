#!/bin/bash
set -euxo pipefail

unset CROSS_COMPILE
unset CC
unset CXX
unset CMAKE_OPTIONS

export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC -fno-rtti"
export HOST="x86_64-linux-gnu"

source ./build-linux.sh

mkdir -p "${ARTIFACTS_DIR}/Linux/amd64"
cp .libs/libleveldbjni.so "${ARTIFACTS_DIR}/Linux/amd64/"