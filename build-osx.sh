#!/bin/bash
set -euxo pipefail
# Note: Not designed to be called directly.  Use either build-osx-aarch64.sh or build-osx-x86.sh


mkdir -p "build/${HOST}"
cd "build/${HOST}"
BUILD_DIR=$PWD
ARTIFACTS_DIR="${BUILD_DIR}/../artifacts"

# grab leveldb source and patch it
git clone git://github.com/chirino/leveldb.git
cd leveldb
git checkout 4a715cd
curl --fail -L -O https://raw.githubusercontent.com/fusesource/leveldbjni/master/leveldb.patch
git apply ./leveldb.patch

# no make install target in leveldb, so manually copy libs
cd "${BUILD_DIR}/leveldb"
# Build with snappy
CXXFLAGS="-I. -I./include -I /usr/local/include -DSNAPPY  -std=c++11" CFLAGS="-I. -I./include -I /usr/local/include -DSNAPPY -std=c++11" make

cd "${BUILD_DIR}"
# grab native source blob from maven
curl --fail -L -O https://repo1.maven.org/maven2/org/fusesource/leveldbjni/leveldbjni/1.8/leveldbjni-1.8-native-src.zip
# build and install
unzip leveldbjni-1.8-native-src.zip
cd leveldbjni-1.8-native-src
chmod +x ./configure
patch < "${BUILD_DIR}/../../configure-osx.patch"
./configure --with-leveldb="${BUILD_DIR}/leveldb" --with-snappy="/usr/local/lib" --with-jni-jdk=`/usr/libexec/java_home -v 11` --enable-static --host=${HOST}
make -j8