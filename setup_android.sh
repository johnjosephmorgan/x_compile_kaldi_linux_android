#!/bin/bash 

# set variables
h=/home/john
ndk_root=$h/android-ndk-r16b
tc_dir=$h/toolchain-aarch64-android
ndk_pkg=android-ndk-r16b-linux-x86_64.zip
api=23

export ANDROID_TOOLCHAIN_PATH=$tc_dir
export PATH=${ANDROID_TOOLCHAIN_PATH}/bin:$PATH
export CLANG_FLAGS="-target arm-linux-androideabi -marm -mfpu=vfp -mfloat-abi=softfp --sysroot ${ANDROID_TOOLCHAIN_PATH}/sysroot -gcc-toolchain ${ANDROID_TOOLCHAIN_PATH}"

cd ~/

echo "Downloading Android NDK."
wget -q --output-document=android-ndk.zip \
     https://dl.google.com/android/repository/$ndk_pkg

echo "unzipping archive."
unzip android-ndk.zip

echo "Install ingthe toolchain."
$ndk_root/build/tools/make_standalone_toolchain.py \
    --arch arm \
    --api $api \
    --stl=libc++ \
    --install-dir $tc_dir \
    --force
