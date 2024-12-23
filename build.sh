#!/bin/bash
#
# Compile script for kernel
#

SECONDS=0 # builtin bash timer

# Allowed codenames
ALLOWED_CODENAMES=("sweet")

# Prompt user for device codename
read -p "Enter device codename: " DEVICE

# Check if the entered codename is in the allowed list
if [[ ! " ${ALLOWED_CODENAMES[@]} " =~ " ${DEVICE} " ]]; then
    echo "Error: Invalid codename. Allowed codenames are: ${ALLOWED_CODENAMES[*]}"
    exit 1
fi

ZIPNAME="SemloheyPerf-$(date '+%Y%m%d-%H%M').zip"

export ARCH=arm64
export KBUILD_BUILD_USER=djancox
export KBUILD_BUILD_HOST=semox
export PATH="/home/los/clang/bin/:$PATH"

git clone -q --depth=1 https://gitea.com/LineVall/Clang.git -b zyc20 /home/los/clang

# Build
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

if [[ $1 = "-c" || $1 = "--clean" ]]; then
	rm -rf out
	echo "Cleaned output folder"
fi

echo "**** Kernel defconfig is set to $KERNEL_DEFCONFIG ****"
echo -e "$blue***********************************************"
echo "          BUILDING KERNEL          "
echo -e "***********************************************$nocol"
echo -e "\nStarting compilation for $DEVICE...\n"
make O=out ARCH=arm64 ${DEVICE}_defconfig
make -j$(nproc) \
    O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi-

kernel="out/arch/arm64/boot/Image.gz"
dtbo="out/arch/arm64/boot/dtbo.img"
dtb="out/arch/arm64/boot/dtb.img"

if [ ! -f "$kernel" ] || [ ! -f "$dtbo" ] || [ ! -f "$dtb" ]; then
	echo -e "\nCompilation failed!"
	exit 1
fi

echo -e "\nKernel compiled successfully! Zipping up...\n"

if [ -d "$AK3_DIR" ]; then
	cp -r $AK3_DIR AnyKernel3
else
	if ! git clone -q https://gitea.com/LineVall/AnyKernel3 -b main AnyKernel3; then
		echo -e "\nAnyKernel3 repo not found locally and couldn't clone from GitHub! Aborting..."
		exit 1
	fi
fi

# Modify anykernel.sh to replace device names
sed -i "s/device\.name1=.*/device.name1=${DEVICE}/" AnyKernel3/anykernel.sh
sed -i "s/device\.name2=.*/device.name2=${DEVICE}in/" AnyKernel3/anykernel.sh

cp $kernel AnyKernel3
cp $dtbo AnyKernel3
cp $dtb AnyKernel3
cd AnyKernel3
zip -r9 "../$ZIPNAME" * -x .git
cd ..
rm -rf AnyKernel3
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
sha1sum $ZIPNAME

if test -z "$(git rev-parse --show-cdup 2>/dev/null)" &&
   head=$(git rev-parse --verify HEAD 2>/dev/null); then
	HASH="$(echo $head | cut -c1-8)"
fi

echo "**** Uploading your zip now ****"
if command -v curl &> /dev/null; then
curl -T $ZIPNAME -u:f0af46bc-25f3-4f8f-95e8-c3bb2647931a https://pixeldrain.com/api/file/
else
echo "Zip: $ZIPNAME"
fi
