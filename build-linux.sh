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

git clone --recurse-submodules -b 1.1.9 https://github.com/google/snappy.git
cd snappy
mkdir build
cd build
cmake ${CMAKE_OPTIONS:-} ../
make snappy

cd "${BUILD_DIR}"

cat <<EOF
************************************
********  Building LevelDB *********
************************************
EOF
# grab leveldb source and patch it
git clone git://github.com/chirino/leveldb.git
cd leveldb
git checkout 4a715cd
wget https://raw.githubusercontent.com/fusesource/leveldbjni/master/leveldb.patch
git apply ./leveldb.patch

# no make install target in leveldb, so manually copy libs
cd "${BUILD_DIR}/leveldb"
CXXFLAGS="${CXXFLAGS:-} -I. -I./include -I ${BUILD_DIR}/snappy -I ${BUILD_DIR}/snappy/build -L ${BUILD_DIR}/snappy/build -DSNAPPY -std=c++11" \
  CFLAGS="${CFLAGS:-} -I. -I./include -I ${BUILD_DIR}/snappy -I ${BUILD_DIR}/snappy/build -DSNAPPY -std=c++11" \
  make libleveldb.a

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
./configure --with-leveldb="${BUILD_DIR}/leveldb" --with-snappy="${BUILD_DIR}/snappy/build" --enable-static --host=${HOST}
make -j8