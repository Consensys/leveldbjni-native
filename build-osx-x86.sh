#!/bin/bash
set -euxo pipefail

export CFLAGS="-arch x86_64"
export CXXFLAGS="-arch x86_64 -fno-rtti"
export HOST="x86_64-apple-darwin"

source ./build-osx.sh

mkdir -p "${ARTIFACTS_DIR}/Mac/x86_64"
cp .libs/libleveldbjni.jnilib "${ARTIFACTS_DIR}/Mac/x86_64/"