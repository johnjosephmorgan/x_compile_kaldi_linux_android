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
    --install-dir $tc_dir

exit
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

echo "Compiling CLAPACK for Android."

cd ~/

git clone https://github.com/simonlynen/android_libs.git

cd $h/android_libs/lapack

# remove some compile instructions related to tests
sed -i 's/LOCAL_MODULE:= testlapack/#LOCAL_MODULE:= testlapack/g' jni/Android.mk
sed -i 's/LOCAL_SRC_FILES:= testclapack.cpp/#LOCAL_SRC_FILES:= testclapack.cpp/g' jni/Android.mk
sed -i 's/LOCAL_STATIC_LIBRARIES := lapack/#LOCAL_STATIC_LIBRARIES := lapack/g' jni/Android.mk
sed -i 's/include $(BUILD_SHARED_LIBRARY)/#include $(BUILD_SHARED_LIBRARY)/g' jni/Android.mk

echo "Building for android."
$ndk_root/ndk-build

cp -R obj/local/armeabi-v7a/ $h/OpenBLAS/install/lib/
exit
echo "Compile kaldi for Android."

echo "Downloading kaldi source code."
cd $h
git clone https://github.com/kaldi-asr/kaldi.git kaldi-android

echo "Compiling OpenFST."
cd $h/kaldi-android/tools

wget -T 10 -t 1 http://www.openfst.org/twiki/pub/FST/FstDownload/openfst-1.6.7.tar.gz

tar -zxvf openfst-1.6.7.tar.gz

cd openfst-1.6.7/

CXX=clang++ ./configure --prefix=`pwd` --enable-static --enable-shared --enable-far --enable-ngram-fsts --host=arm-linux-androideabi LIBS="-ldl"

make -j 8

make install

cd ..

ln -s openfst-1.6.7 openfst

echo "Compiling src."
cd ../src

#Be sure android-toolchain is in your $PATH before the next step
CXX=clang++ ./configure --static --android-incdir=$tc_dir/sysroot/usr/include/ --host=arm-linux-androideabi --openblas-root=$h/OpenBLAS/install
CXX=clang++ ./configure --static --android-incdir=$tc_dir/sysroot/usr/include/ --host=arm-linux-androideabi --openblas-root=$h/OpenBLAS/install

#You may want to compile Kaldi without debugging symbols.
#In this case, do:
sed -i 's/-g # -O0 -DKALDI_PARANOID/-O3 -DNDEBUG/g' kaldi.mk

make clean -j 8

make depend -j 8

make -j 8
