#!/bin/bash
#
# Compile script for AOSPA GKI (AK3) for marble
# Copyright (C) 2023 Adithya R.

SECONDS=0 # builtin bash timer

ZIPNAME="aospa-gki-marble-$(date '+%Y%m%d-%H%M').zip"
if test -z "$(git -C common rev-parse --show-cdup 2>/dev/null)" &&
   head=$(git -C common rev-parse --verify HEAD 2>/dev/null); then
	ZIPNAME="${ZIPNAME::-4}-$(echo $head | cut -c1-8).zip"
fi

echo -e "Starting build...\n"

export BUILD_CONFIG=common/build.config.gki.aarch64
export SKIP_MRPROPER=1

while [ "$#" -gt 0 ]; do
	case "$1" in
		-c | --clean)
			export SKIP_MRPROPER=0
			;;
		-f | --full-lto)
			export LTO=full
			;;
		# TODO: -r | --regen defconfig
	esac
	shift
done

build/build.sh 2> >(tee error.log >&2) || exit $?

echo -e "\nKernel built succesfully! Zipping up...\n"
cp out/android12-5.10/dist/Image AnyKernel3
cd AnyKernel3
zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
cd ..
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) :"
echo "$(realpath $ZIPNAME)"
