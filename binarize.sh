#!/bin/bash

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

