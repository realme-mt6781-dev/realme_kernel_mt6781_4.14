#!/bin/bash
clear
function compile() 
{
echo COSMOS Kernel, CODENAMED - SPACED
echo
sleep 3 >/dev/null
source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G >/dev/null
export ARCH=arm64
export KBUILD_BUILD_HOST=COSMOS
export KBUILD_BUILD_USER="INFIX"
git clone --depth=1 https://gitlab.com/Panchajanya1999/azure-clang.git clang

read -p "Wanna do dirty build? (Y/N): " build_type
if [[ $build_type == "N" || $build_type == "n" ]]; then
echo Deleting out directory and doing clean Build
sleep 3 >/dev/null
rm -rf out && mkdir -p out
fi
if [[ $build_type == "Y" || $build_type == "y" ]]; then
echo Warning :- Doing dirty build
sleep 3 >/dev/null
fi
if ! [[ $build_type == "Y" || $build_type == "y" ]]; then
if ! [[ $build_type == "N" || $build_type == "n" ]]; then
echo Invalid Input , Read carefully before typing
echo Trying to restart script
sleep 3 >/dev/null
. build.sh && exit
fi
fi

make O=out ARCH=arm64 spaced_defconfig

PATH="${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      LD=ld.lld \
		      AR=llvm-ar \
		      NM=llvm-nm \
		      OBJCOPY=llvm-objcopy \
		      OBJDUMP=llvm-objdump \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${PWD}/clang/bin/aarch64-linux-gnu-" \
                      CROSS_COMPILE_ARM32="${PWD}/clang/bin/arm-linux-gnueabi-" \
                      CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee error.log 
}

function zupload()
{
git clone --depth=1 https://github.com/HELLINFIX/AnyKernel3.git AnyKernel
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
cd AnyKernel
zip -r9 Cosmos-kernel-1.0-spaced.zip *
curl -sL https://git.io/file-transfer | sh
./transfer anon Cosmos-kernel-1.0-spaced.zip
}

compile
zupload