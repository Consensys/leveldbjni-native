#!/bin/bash
set -euxo pipefail

export HOST="aarch64-apple-darwin"
export CMAKE_OPTIONS="-DCMAKE_OSX_ARCHITECTURES=arm64 -DHAVE_STD_REGEX=ON -DRUN_HAVE_STD_REGEX=1"
export CFLAGS="-arch arm64"
export CXXFLAGS="-arch arm64 -fno-rtti"

source ./build-osx.sh

mkdir -p "${ARTIFACTS_DIR}/Mac/aarch64"
cp .libs/libleveldbjni.jnilib "${ARTIFACTS_DIR}/Mac/aarch64/"