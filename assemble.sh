#!/bin/bash
set -euxo pipefail


RESOURCEDIR="src/main/resources/META-INF/native"
mkdir -p "${RESOURCEDIR}"

BUILD_DIR="build"

cp -rf ${BUILD_DIR}/artifacts/* "${RESOURCEDIR}"

./gradlew build