#!/bin/bash

## define number of threads to use
NCORE=8

## export more log messages
set -x
set -e

mkdir mask

## raw inputs
ANAT=`jq -r '.anat' config.json`

# convert anatomical t1 to mrtrix format
[ ! -f anat.mif ] && mrconvert ${ANAT} anat.mif -nthreads $NCORE

## convert anatomy
[ ! -f 5tt.mif ] && 5ttgen fsl anat.mif 5tt.mif -nocrop -sgm_amyg_hipp -tempdir ./tmp -force -nthreads $NCORE -quiet

# 5 tissue type visualization
[ ! -f ./mask/mask.nii.gz ] && mrconvert 5tt.mif -stride 1,2,3,4 ./mask/mask.nii.gz -force -nthreads $NCORE

# clean up
if [ -f ./mask/mask.nii.gz ]; then
	rm -rf *.mif* ./tmp
else
	echo "mask generation failed"
	exit 1;
fi
