#!/bin/bash
# CJL; (cjl2007@med.cornell.edu)
# note: this script is a wrapper for the HCP's anatomical preprocessing pipeline; 

StudyFolder=$1 # location of Subject folder
Subject=$2 # space delimited list of subject IDs
export NSLOTS=$3 # set number of cores for FreeSurfer

# reformat subject folder path  
if [ "${StudyFolder: -1}" = "/" ]; then
	StudyFolder=${StudyFolder%?};
fi

# Set variable value that sets up environment
EnvironmentScript="/home/cputest/Stroke/Code/HCPpipelines/Examples/Scripts/SetUpHCPPipeline.sh" # Pipeline environment script; users need to set this 
source ${EnvironmentScript}	# Set up pipeline environment variables and software
PRINTCOM="" # If PRINTCOM is not a null or empty string variable, then this script and other scripts that it calls will simply print out the primary commands it otherwise would run. This printing will be done using the command specified in the PRINTCOM variable

AvgrdcSTRING="NONE" # Readout Distortion Correction;
MagnitudeInputName="NONE" # The MagnitudeInputName variable should be set to a 4D magitude volume with two 3D timepoints or "NONE" if not used
PhaseInputName="NONE" # The PhaseInputName variable should be set to a 3D phase difference volume or "NONE" if not used
TE="2.46ms" # The TE variable should be set to 2.46ms for 3T scanner, 1.02ms for 7T scanner or "NONE" if not using

# Variables related to using Spin Echo Field Maps
SpinEchoPhaseEncodeNegative="NONE"
SpinEchoPhaseEncodePositive="NONE"
SEEchoSpacing="NONE"
SEUnwarpDir="NONE"
TopupConfig="NONE"
GEB0InputName="NONE"

# define some templates;
T1wTemplate="${HCPPIPEDIR_Templates}/MNI152_T1_0.8mm.nii.gz" # Hires T1w MNI template
T1wTemplateBrain="${HCPPIPEDIR_Templates}/MNI152_T1_0.8mm_brain.nii.gz" # Hires brain extracted MNI template
T1wTemplate2mm="${HCPPIPEDIR_Templates}/MNI152_T1_2mm.nii.gz" # Lowres T1w MNI template
T2wTemplate="${HCPPIPEDIR_Templates}/MNI152_T2_0.8mm.nii.gz" # Hires T2w MNI Template
T2wTemplateBrain="${HCPPIPEDIR_Templates}/MNI152_T2_0.8mm_brain.nii.gz" # Hires T2w brain extracted MNI Template
T2wTemplate2mm="${HCPPIPEDIR_Templates}/MNI152_T2_2mm.nii.gz" # Lowres T2w MNI Template
TemplateMask="${HCPPIPEDIR_Templates}/MNI152_T1_0.8mm_brain_mask.nii.gz" # Hires MNI brain mask template
Template2mmMask="${HCPPIPEDIR_Templates}/MNI152_T1_2mm_brain_mask_dil.nii.gz" # Lowres MNI brain mask template


# Structural Scan Settings
# The values set below are for the HCP-YA Protocol using the Siemens Connectom Scanner
T1wSampleSpacing="NONE" # DICOM field (0019,1018) in s or "NONE" if not used
T2wSampleSpacing="NONE" # DICOM field (0019,1018) in s or "NONE" if not used
UnwarpDir="z" # z appears to be the appropriate polarity for the 3D structurals collected on Siemens scanners
BrainSize="170" # BrainSize in mm, 150-170 for humans
FNIRTConfig="${HCPPIPEDIR_Config}/T1_2_MNI152_2mm.cnf" # FNIRT 2mm T1w Config
GradientDistortionCoeffs="NONE" # Set to NONE to skip gradient distortion correction

time3=$(date "+%Y-%m-%d %H:%M:%S") && echo -e "\n${time3} Anatomical Preprocessing and Surface Registration Pipeline"

# clean slate;
rm -rf ${StudyFolder}/${Subject}/T*w/ > /dev/null 2>&1 
rm -rf ${StudyFolder}/${Subject}/MNINonLinear > /dev/null 2>&1 

# build list of full paths to T1w images; 
T1ws=`ls ${StudyFolder}/${Subject}/anat/unprocessed/T1w/T1w*.nii.gz`

T1wInputImages="" # preallocate 

# find all 
# T1w images;
for i in $T1ws ; do
	T1wInputImages=`echo "${T1wInputImages}$i@"`
done

# build list of full paths to T1w images;
T2ws=`ls ${StudyFolder}/${Subject}/anat/unprocessed/T2w/T2w*.nii.gz` > /dev/null 2>&1  
T2wInputImages="" # preallocate 

# find all 
# T2w images;
for i in $T2ws ; do
	T2wInputImages=`echo "${T2wInputImages}$i@"`
done

# determine if T2w images exist & 
# adjust "processing mode" accordingly
if [ "$T2wInputImages" = "" ]; then
	T2wInputImages="NONE" # script will proceed in "legacy" mode
	ProcessingMode="LegacyStyleData"
else
	ProcessingMode="HCPStyleData"
fi

# make "QA" folder;
mkdir ${StudyFolder}/${Subject}/qa/ > /dev/null 2>&1 

time3=$(date "+%Y-%m-%d %H:%M:%S") && echo "${time3} ------------------------Running PreFreeSurferPipeline"

# run the Pre FreeSurfer pipeline;
${HCPPIPEDIR}/PreFreeSurfer/PreFreeSurferPipeline.sh \
--path="$StudyFolder" \
--subject="$Subject" \
--t1="$T1wInputImages" \
--t2="$T2wInputImages" \
--t1template="$T1wTemplate" \
--t1templatebrain="$T1wTemplateBrain" \
--t1template2mm="$T1wTemplate2mm" \
--t2template="$T2wTemplate" \
--t2templatebrain="$T2wTemplateBrain" \
--t2template2mm="$T2wTemplate2mm" \
--templatemask="$TemplateMask" \
--template2mmmask="$Template2mmMask" \
--brainsize="$BrainSize" \
--fnirtconfig="$FNIRTConfig" \
--fmapmag="$MagnitudeInputName" \
--fmapphase="$PhaseInputName" \
--fmapgeneralelectric="$GEB0InputName" \
--echodiff="$TE" \
--SEPhaseNeg="$SpinEchoPhaseEncodeNegative" \
--SEPhasePos="$SpinEchoPhaseEncodePositive" \
--seechospacing="$SEEchoSpacing" \
--seunwarpdir="$SEUnwarpDir" \
--t1samplespacing="$T1wSampleSpacing" \
--t2samplespacing="$T2wSampleSpacing" \
--unwarpdir="$UnwarpDir" \
--gdcoeffs="$GradientDistortionCoeffs" \
--avgrdcmethod="$AvgrdcSTRING" \
--topupconfig="$TopupConfig" \
--processing-mode="$ProcessingMode" \
--printcom=$PRINTCOM > ${StudyFolder}/${Subject}/qa/PreFreeSurfer.txt

time3=$(date "+%Y-%m-%d %H:%M:%S") && echo "${time3} ------------------------Running done"

# define some input variables for FreeSurfer;
SubjectID="$Subject" #FreeSurfer Subject ID Name
SubjectDIR="${StudyFolder}/${Subject}/T1w" #Location to Put FreeSurfer Subject's Folder
T1wImage="${StudyFolder}/${Subject}/T1w/T1w_acpc_dc_restore.nii.gz" #T1w FreeSurfer Input (Full Resolution)
T1wImageBrain="${StudyFolder}/${Subject}/T1w/T1w_acpc_dc_restore_brain.nii.gz" #T1w FreeSurfer Input (Full Resolution)


# determine if T2w images exist & 
# adjust "T2wImage" input accordingly
if [ "$T2wInputImages" = "NONE" ]; then
	T2wImage="NONE" # no T2w image
else
	T2wImage="${StudyFolder}/${Subject}/T1w/T2w_acpc_dc_restore.nii.gz" #T2w FreeSurfer Input (Full Resolution)
fi

time3=$(date "+%Y-%m-%d %H:%M:%S") && echo "${time3} ------------------------Running FreeSurferPipeline"

# run the FreeSurfer pipeline;
${HCPPIPEDIR}/FreeSurfer/FreeSurferPipeline.sh \
--subject="$Subject" \
--subjectDIR="$SubjectDIR" \
--t1="$T1wImage" \
--t1brain="$T1wImageBrain" \
--t2="$T2wImage" \
--processing-mode="$ProcessingMode" > ${StudyFolder}/${Subject}/qa/FreeSurfer.txt
