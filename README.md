# LevelDB Native

Provides an automated build for [LevelDB JNI](https://github.com/fusesource/leveldbjni).

## Current Status

Building supported on:

* Linux (x86_64)
* Mac (x86_64)
* Mac (aarch64)

Desired but unsupported:

* Linux (aarch64)
    * Not supported by the version of LevelDB currently required by leveldbjni.
    * A script is provided that cross-compiles, but leveldb is missing an AtomicPointer implementation for aarch64. 
* Windows (x86)
    * Automated build not yet figured out.
    * Likely need to update the Visual Studio project at minimum.

## Building

The definitive process for building is defined in the [CircleCI config](.circleci/config.yml).
Generally however building involves running the `./build-<platform>.sh` script for the current
platform followed by `./assemble.sh` to build and test the resulting jar.

The aarch64 builds use cross-compilation so can be run (but not tested) on x86 machines.

Building a multiplatform jar requires running the required `./build-<platform>.sh` script for each
platform, potentially on multiple systems, then combining the results in `build/artifacts` before
running `./assemble.sh`.