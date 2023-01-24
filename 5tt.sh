#!/bin/bash

## define number of threads to use
NCORE=4

## export more log messages
set -x
set -e

mkdir -p mask

## raw inputs
freesurfer=`jq -r '.freesurfer' config.json`
hippocampal=`jq -r '.hippocampal' config.json`
thalami=`jq -r '.thalami' config.json`
white_stem=`jq -r '.white_stem' config.json`
nocrop=`jq -r '.nocrop' config.json`
sgm_amyg_hipp=`jq -r '.sgm_amyg_hipp' config.json`
template=`jq -r '.input' config.json`

# parse configs
if [[ -f ${template} ]]; then
	temp_line="-template $(eval "echo $template)"
else
	temp_line=''
fi

if [[ ! ${hippocampal} == '' ]]; then
	hipp_line="-hippocampal $(eval "echo $hippocampal")"
else
	hipp_line=''
fi

if [[ ! ${thalami} == '' ]]; then
	thal_line="-thalami $(eval "echo $thalami")"
else
	thal_line=''
fi

if [[ ! ${white_stem} == '' ]]; then
	ws_line='-white_stem'
else
	ws_line=''
fi

if [[ ! ${nocrop} == '' ]]; then
	nc_line='-nocrop'
else
	nc_line=''
fi

if [[ ! ${sgm_amyg_hipp} == '' ]]; then
	sah_line='-sgm_amyg_hipp'
else
	sah_line=''
fi

## convert anatomy
if [ ! -f 5tt.mif ]; then
	5ttgen hsvs ${freesurfer} 5tt.mif ${temp_line} ${hipp_line} ${thal_line} ${ws_line} ${nc_line} ${sah_line} -force -nthreads $NCORE -quiet
fi

# 5 tissue type visualization
[ ! -f ./mask/mask.nii.gz ] && mrconvert 5tt.mif -stride 1,2,3,4 ./mask/mask.nii.gz -force -nthreads $NCORE

# check
[ ! -f ./mask/mask.nii.gz ] && echo "something went wrong, check logs and derivatives" && exit 1