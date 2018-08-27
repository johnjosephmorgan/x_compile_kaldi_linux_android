#/bin/bash

# set variables
h=/home/john
ndk_root=$h/android-ndk-r16b
tc_dir=$h/toolchain-aarch64-android
export ANDROID_TOOLCHAIN_PATH=$tc_dir
export PATH=${ANDROID_TOOLCHAIN_PATH}/bin:$PATH
export CLANG_FLAGS="-target arm-linux-androideabi -marm -mfpu=vfp -mfloat-abi=softfp --sysroot ${ANDROID_TOOLCHAIN_PATH}/sysroot -gcc-toolchain ${ANDROID_TOOLCHAIN_PATH}"


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

CXX=clang++ ./configure --static --android-incdir=$tc_dir/sysroot/usr/include/ --host=arm-linux-androideabi --openblas-root=$h/OpenBLAS/install
CXX=clang++ ./configure --static --android-incdir=$tc_dir/sysroot/usr/include/ --host=arm-linux-androideabi --openblas-root=$h/OpenBLAS/install

# Compile Kaldi without debugging symbols.
sed -i 's/-g # -O0 -DKALDI_PARANOID/-O3 -DNDEBUG/g' kaldi.mk

make clean -j 8

make depend -j 8

make -j 8
