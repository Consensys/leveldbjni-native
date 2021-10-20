#!/bin/bash
set -euxo pipefail

mkdir -p build
cd build
BUILD_DIR=$PWD

apt update
apt install -y git build-essential automake unzip wget
# grab leveldb source and patch it
git clone git://github.com/chirino/leveldb.git
cd leveldb
git checkout 4a715cd
wget https://raw.githubusercontent.com/fusesource/leveldbjni/master/leveldb.patch
git apply ./leveldb.patch

# no make install target in leveldb, so manually copy libs
cd "${BUILD_DIR}/leveldb"
make -j3

cd "${BUILD_DIR}"
# grab native source blob from maven
wget https://repo1.maven.org/maven2/org/fusesource/leveldbjni/leveldbjni/1.8/leveldbjni-1.8-native-src.zip
# build and install
unzip leveldbjni-1.8-native-src.zip
cd leveldbjni-1.8-native-src
chmod +x ./configure
./configure --with-leveldb="${BUILD_DIR}/leveldb"
make -j8
g++ -shared -o .libs/libleveldbjni.so -Wl,--whole-archive .libs/*.o ../leveldb/libleveldb.a -Wl,--no-whole-archive
mkdir -p "${BUILD_DIR}/artifacts/linux64/"
cp .libs/libleveldbjni.so "${BUILD_DIR}/artifacts/linux64/"