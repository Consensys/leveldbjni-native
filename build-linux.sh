#!/bin/bash
set -euxo pipefail

mkdir -p build/linux
cd build/linux
BUILD_DIR=$PWD
ARTIFACTS_DIR="${BUILD_DIR}/../artifacts"

apt update
apt install -y git build-essential automake unzip wget cmake

cat <<EOF
************************************
********  Building Snappy **********
************************************
EOF

git clone --recurse-submodules -b 1.1.9 https://github.com/google/snappy.git
cd snappy
mkdir build
cd build
CFLAGS="-fPIC" CXXFLAGS="-fPIC" cmake ../
CFLAGS="-fPIC" CXXFLAGS="-fPIC" make snappy

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
  make

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
./configure --with-leveldb="${BUILD_DIR}/leveldb" --with-snappy="${BUILD_DIR}/snappy/build" --enable-static
make -j8
g++ -shared -o .libs/libleveldbjni.so -Wl,--whole-archive .libs/*.o ../leveldb/libleveldb.a ../snappy/build/libsnappy.a -Wl,--no-whole-archive


mkdir -p "${ARTIFACTS_DIR}/linux64/"
cp .libs/libleveldbjni.so "${ARTIFACTS_DIR}/linux64/"