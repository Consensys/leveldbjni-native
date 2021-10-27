$ErrorActionPreference = "Stop"
mkdir -p build/windows
cd build/windows
$Env:BUILD_DIR = $pwd
$Env:ARTIFACTS_DIR = "$Env:BUILD_DIR/../artifacts"

# choco install -y cmake
$Env:PATH += ";C:\Program Files\CMake\bin"

git clone --recurse-submodules -b 1.1.9 https://github.com/google/snappy.git
cd snappy
git apply $Env:BUILD_DIR\..\..\snappy.patch
cmake -G "Visual Studio 16 2019" -A x64 .
cmake --build .

cd $Env:BUILD_DIR
git clone --recurse-submodules -b 1.23 https://github.com/google/leveldb.git
cd leveldb
git apply $Env:BUILD_DIR\..\..\snappy.patch
cmake -G "Visual Studio 16 2019" -A x64 .
cmake --build .