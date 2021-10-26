$ErrorActionPreference = "Stop"
mkdir -p build/windows
cd build/windows
$Env:BUILD_DIR = $pwd
$Env:ARTIFACTS_DIR = "$Env:BUILD_DIR/../artifacts"

# choco install -y cmake
$Env:PATH += ";C:\Program Files\CMake\bin"

git clone --recurse-submodules -b 1.1.8_leveldbjni https://github.com/albertsteckermeier/snappy.git
cd snappy
cmake -G "Visual Studio 16 2019" -A x64 .
cmake --build .

cd $Env:BUILD_DIR
git clone --recurse-submodules -b 1.22_leveldbjni https://github.com/albertsteckermeier/leveldb.git
cd leveldb
cmake -G "Visual Studio 16 2019" -A x64 .
cmake --build .