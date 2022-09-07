#!/bin/bash
set -euxo pipefail

export HOST="aarch64-apple-darwin"
export CMAKE_OPTIONS="-DCMAKE_OSX_ARCHITECTURES=arm64 -DRUN_HAVE_STD_REGEX=0 -DRUN_HAVE_POSIX_REGEX=0 -DHAVE_CXX_FLAG_WD654=0 -DLEVELDB_BUILD_BENCHMARKS=OFF"
export CFLAGS="-arch arm64"
export CXXFLAGS="-arch arm64 -v -stdlib=libc++"

source ./build-osx.sh

mkdir -p "${ARTIFACTS_DIR}/Mac/aarch64"
cp .libs/libleveldbjni.jnilib "${ARTIFACTS_DIR}/Mac/aarch64/"