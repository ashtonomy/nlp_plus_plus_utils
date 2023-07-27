#!/bin/bash

# Installing engine on Palmetto Cluster

# 1. Install spack from source.
git clone -c feature.manyFiles=true https://github.com/spack/spack.git

source spack/share/spack/setup-env.sh

# 2. Install and load dependencies with spack
spack find # This should be empty
spack install autoconf-archive
spack install icu4c

ac_archive=$(spack find autoconf_archive | grep -Eo "autoconf-archive@\S*")
spack load $ac_archive

icu=$(spack find icu4c | grep -Eo "icu4c@\S*")
spack load $icu

# 3. Clone engine
git clone --recurse-submodules https://github.com/visualtext/nlp-engine
cd nlp-engine

# 4. Fetch vcpkg libraries
cd vcpkg
./bootstrap-vcpkg.sh
./vcpkg install

# 5. Build with cmake
cd .. 
cmake -DCMAKE_BUILD_TYPE=Debug build -S . 
-DCMAKE_TOOLCHAIN_FILE='./vcpkg/scripts/buildsystems/vcpkg.cmake'
cmake --build build/ --target all



