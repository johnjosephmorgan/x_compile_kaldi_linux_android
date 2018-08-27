#!/bin/bash 

# set variables
h=/home/john
ndk_root=$h/android-ndk-r16b
tc_dir=$h/toolchain-aarch64-android
export ANDROID_TOOLCHAIN_PATH=$tc_dir
export PATH=${ANDROID_TOOLCHAIN_PATH}/bin:$PATH
export CLANG_FLAGS="-target arm-linux-androideabi -marm -mfpu=vfp -mfloat-abi=softfp --sysroot ${ANDROID_TOOLCHAIN_PATH}/sysroot -gcc-toolchain ${ANDROID_TOOLCHAIN_PATH}"

echo "Compiling CLAPACK for Android."
cd ~/
git clone https://github.com/simonlynen/android_libs.git

cd $h/android_libs/lapack

# remove some compile instructions related to tests
sed -i 's/LOCAL_MODULE:= testlapack/#LOCAL_MODULE:= testlapack/g' jni/Android.mk
sed -i 's/LOCAL_SRC_FILES:= testclapack.cpp/#LOCAL_SRC_FILES:= testclapack.cpp/g' jni/Android.mk
sed -i 's/LOCAL_STATIC_LIBRARIES := lapack/#LOCAL_STATIC_LIBRARIES := lapack/g' jni/Android.mk
sed -i 's/include $(BUILD_SHARED_LIBRARY)/#include $(BUILD_SHARED_LIBRARY)/g' jni/Android.mk

echo "Building clapac for android."
$ndk_root/ndk-build

cp -R obj/local/armeabi-v7a/ $h/OpenBLAS/install/lib/
cp  obj/local/armeabi-v7a/* $h/OpenBLAS/install/lib/
