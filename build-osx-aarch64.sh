#!/bin/bash
set -euxo pipefail

export CC="cc -arch arm64"
export CXX="c++ -arch arm64"
export HOST="aarch64-apple-darwin"

source ./build-osx.sh

mkdir -p "${ARTIFACTS_DIR}/osx/aarch64"
cp .libs/libleveldbjni.jnilib "${ARTIFACTS_DIR}/osx/aarch64/"