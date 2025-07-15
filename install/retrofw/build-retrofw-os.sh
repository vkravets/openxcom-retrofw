#!/usr/bin/env bash
set -euo pipefail

declare -r ARCH=mipsel-RetroFW-linux-uclibc-
declare -r AS=${ARCH}as
declare -r CC=${ARCH}cc
declare -r CXX=${ARCH}g++
declare -r LD=${ARCH}ld
declare -r BUILD_DIR=build-rg97-retrofw

declare -r CXXFLAGS="-march=mips32 -DNO_STACK_TRACE=1 -DGAMEPAD_ENABLED=1 -DDINGOO"

cd ../../

if [ ${@,,} == "clean" ]; then
    echo Cleaning $BUILD_DIR
    rm -rf $BUILD_DIR
fi

if ! [ -d "$BUILD_DIR" ]; then
    mkdir $BUILD_DIR
fi

cd $BUILD_DIR

cmake -DCMAKE_CXX_FLAGS="$CXXFLAGS" -DCMAKE_FIND_ROOT_PATH=\"/opt/rs97tools/mipsel-RetroFW-linux-uclibc/\" -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=mipsel -DCMAKE_C_COMPILER=${ARCH}gcc -DCMAKE_CXX_COMPILER=${ARCH}g++ ../

re='^[0-9]+$'
if ! [[ $@ =~ $re ]]; then
    make
else
    make -j$@
fi

if [ -d "ROMS" ]; then
    rm -rf ROMS
fi
if [ -f "README.txt" ]; then
    rm README.txt
fi
if [ -f "openxcom-rg35xx-garlic.zip" ]; then
    rm openxcom-rg35xx-garlic.zip
fi
cd ../install/rg35xx/garlicos-skeleton
cp -r ROMS ../../../$BUILD_DIR
cp -r README.txt ../../../$BUILD_DIR
cd ../../../$BUILD_DIR/bin
mv * ../ROMS/PORTS/openxcom
cd ../
zip -r openxcom-rg35xx-garlic.zip ROMS
zip -r openxcom-rg35xx-garlic.zip README.txt

