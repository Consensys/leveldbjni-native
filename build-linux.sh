#!/bin/bash
set -euxo pipefail

mkdir -p build/${HOST}
cd build/${HOST}
BUILD_DIR=$PWD
ARTIFACTS_DIR="${BUILD_DIR}/../artifacts"

apt update
apt install -y git build-essential automake unzip wget cmake gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu g++-aarch64-linux-gnu

cat <<EOF
************************************
********  Building Snappy **********
************************************
EOF

git clone --recurse-submodules -b 1.1.10 https://github.com/google/snappy.git
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
  LDFLAGS="${LDFLAGS:-} -L${BUILD_DIR}/snappy/ -lstdc++" \
  cmake -DCMAKE_BUILD_TYPE=Release ${CMAKE_OPTIONS:-} .

CXXFLAGS="${CXXFLAGS:-} -I${BUILD_DIR}/snappy/" \
  LDFLAGS="${LDFLAGS:-} -L${BUILD_DIR}/snappy/ -lstdc++" \
  cmake --build . --target leveldb

cd "${BUILD_DIR}"

cat <<EOF
************************************
******  Building LevelDB JNI *******
************************************
EOF
# grab native source blob from maven
wget https://repo1.maven.org/maven2/org/fusesource/leveldbjni/leveldbjni/1.8/leveldbjni-1.8-native-src.zip
# build and install
unzip leveldbjni-1.8-native-src.zip
cd leveldbjni-1.8-native-src
chmod +x ./configure
./configure --with-leveldb="${BUILD_DIR}/leveldb" --with-snappy="${BUILD_DIR}/snappy" --enable-static --host=${HOST}
make -j8