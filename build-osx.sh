#!/bin/bash
set -euxo pipefail
# Note: Not designed to be called directly.  Use either build-osx-aarch64.sh or build-osx-x86.sh


mkdir -p "build/${HOST}"
cd "build/${HOST}"
BUILD_DIR=$PWD
ARTIFACTS_DIR="${BUILD_DIR}/../artifacts"

cat <<EOF
************************************
********  Building Snappy **********
************************************
EOF

git clone --recurse-submodules -b 1.1.9 https://github.com/google/snappy.git
cd snappy
git apply ${BUILD_DIR}/../../snappy.patch
cmake ${CMAKE_OPTIONS:-} .
make snappy

cd "${BUILD_DIR}"


cat <<EOF
************************************
********  Building LevelDB *********
************************************
EOF
# grab leveldb source and patch it
git clone --recurse-submodules -b 1.23 https://github.com/google/leveldb.git
cd leveldb
git apply ${BUILD_DIR}/../../leveldb.patch
CXXFLAGS="${CXXFLAGS:-} -I${BUILD_DIR}/snappy/" \
  LDFLAGS="${LDFLAGS:-} -L${BUILD_DIR}/snappy/ -lc++" \
  cmake -DCMAKE_BUILD_TYPE=Release .

CXXFLAGS="${CXXFLAGS:-} -I${BUILD_DIR}/snappy/" \
  LDFLAGS="${LDFLAGS:-} -L${BUILD_DIR}/snappy/ -lc++" \
  cmake --build . --target leveldb

cat <<EOF
************************************
******  Building LevelDB JNI *******
************************************
EOF
cd "${BUILD_DIR}"
# grab native source blob from maven
curl --fail -L -O https://repo1.maven.org/maven2/org/fusesource/leveldbjni/leveldbjni/1.8/leveldbjni-1.8-native-src.zip
# build and install
unzip leveldbjni-1.8-native-src.zip
cd leveldbjni-1.8-native-src
chmod +x ./configure
patch < "${BUILD_DIR}/../../configure-osx.patch"
CXXFLAGS="${CXXFLAGS:-} -std=c++11" ./configure --with-leveldb="${BUILD_DIR}/leveldb" --with-snappy="${BUILD_DIR}/snappy" --with-jni-jdk=`/usr/libexec/java_home -v 11` --enable-static --host=${HOST}
make -j8