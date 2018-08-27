#!/bin/bash 

h=/home/john
ndk_root=$h/android-ndk-r16b
tc_dir=$h/toolchain-aarch64-android
export ANDROID_TOOLCHAIN_PATH=$tc_dir
export PATH=${ANDROID_TOOLCHAIN_PATH}/bin:$PATH
export CLANG_FLAGS="-target arm-linux-androideabi -marm -mfpu=vfp -mfloat-abi=softfp --sysroot ${ANDROID_TOOLCHAIN_PATH}/sysroot -gcc-toolchain ${ANDROID_TOOLCHAIN_PATH}"

cd ~/

echo "Compiling OpenBLAS for Android."
git clone https://github.com/xianyi/OpenBLAS

cd OpenBLAS

make \
    TARGET=ARMV7 \
    ONLY_CBLAS=1 \
    AR=ar \
    CC="clang ${CLANG_FLAGS}" \
    HOSTCC=gcc \
    ARM_SOFTFP_ABI=1 \
    USE_THREAD=0 \
    NUM_THREADS=32

echo "Installing library."

make install NO_SHARED=1 PREFIX=`pwd`/install
