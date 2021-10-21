#!/bin/bash
set -euxo pipefail

export CC="cc -arch x86_64"
export CXX="c++ -arch x86_64"
export HOST="x86_64-apple-darwin"

source ./build-osx.sh

mkdir -p "${ARTIFACTS_DIR}/Mac/x86_64"
cp .libs/libleveldbjni.jnilib "${ARTIFACTS_DIR}/Mac/x86_64/"