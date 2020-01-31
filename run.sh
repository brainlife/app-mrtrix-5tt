#!/bin/bash

## define number of threads to use
NCORE=4

## export more log messages
set -x
set -e

mkdir -p mask

## raw inputs
ANAT=`jq -r '.anat' config.json`
premasked=`jq -r '.premask' config.json`

# convert anatomical t1 to mrtrix format
[ ! -f anat.mif ] && mrconvert ${ANAT} anat.mif -nthreads $NCORE

## convert anatomy
if [ ! -f 5tt.mif ]; then
	if [[ ${premasked} == 'false' ]]; then
		5ttgen fsl anat.mif 5tt.mif -nocrop -sgm_amyg_hipp -tempdir ./tmp -force -nthreads $NCORE -quiet
	else
		5ttgen fsl anat.mif 5tt.mif -premasked -nocrop -sgm_amyg_hipp -tempdir ./tmp -force -nthreads $NCORE -quiet
	fi
fi

# 5 tissue type visualization
[ ! -f ./mask/mask.nii.gz ] && mrconvert 5tt.mif -stride 1,2,3,4 ./mask/mask.nii.gz -force -nthreads $NCORE

if [ ! -f ./mask/gm.nii.gz ]; then
       	mrconvert -coord 3 0 5tt.mif gm_prob.mif -force -nthreads $NCORE
	mrconvert gm_prob.mif -stride 1,2,3,4 gm_prob.nii.gz -force -nthreads $NCORE
	fslmaths gm_prob.nii.gz -bin ./mask/gm.nii.gz
fi

if [ ! -f ./mask/wm.nii.gz ]; then
        mrconvert -coord 3 2 5tt.mif wm_prob.mif -force -nthreads $NCORE
        mrconvert wm_prob.mif -stride 1,2,3,4 wm_prob.nii.gz -force -nthreads $NCORE
        fslmaths wm_prob.nii.gz -bin ./mask/wm.nii.gz
fi

if [ ! -f ./mask/csf.nii.gz ]; then
        mrconvert -coord 3 3 5tt.mif csf_prob.mif -force -nthreads $NCORE
        mrconvert csf_prob.mif -stride 1,2,3,4 csf_prob.nii.gz -force -nthreads $NCORE
        fslmaths csf_prob.nii.gz -bin ./mask/csf.nii.gz
fi

# clean up
if [ -f ./mask/csf.nii.gz ]; then
	rm -rf *.mif* ./tmp
else
	echo "mask generation failed"
	exit 1;
fi
