#!/bin/bash
set -euxo pipefail

mkdir -p build
cd build
BUILD_DIR=$PWD

#apt update
#apt install -y git build-essential automake unzip wget
# grab leveldb source and patch it
git clone git://github.com/chirino/leveldb.git
cd leveldb
git checkout 4a715cd
curl --fail -L -O https://raw.githubusercontent.com/fusesource/leveldbjni/master/leveldb.patch
git apply ./leveldb.patch

# no make install target in leveldb, so manually copy libs
cd "${BUILD_DIR}/leveldb"
make -j3

cd "${BUILD_DIR}"
# grab native source blob from maven
curl --fail -L -O https://repo1.maven.org/maven2/org/fusesource/leveldbjni/leveldbjni/1.8/leveldbjni-1.8-native-src.zip
# build and install
unzip leveldbjni-1.8-native-src.zip
cd leveldbjni-1.8-native-src
chmod +x ./configure
patch < "${BUILD_DIR}/../configure-osx.patch"
./configure --with-leveldb="${BUILD_DIR}/leveldb" --with-jni-jdk=`/usr/libexec/java_home -v 11` --enable-static
make -j8

mkdir -p "${BUILD_DIR}/artifacts/osx/"
cp .libs/libleveldbjni.jnilib "${BUILD_DIR}/artifacts/osx/"