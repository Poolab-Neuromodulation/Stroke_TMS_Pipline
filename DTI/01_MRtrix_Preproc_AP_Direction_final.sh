#!/bin/bash

# Written by Andrew Jahn, University of Michigan, 02.25.2019
# Updated 07.10.2020 to incorporate changes from MRtrix version 3.0.1
# Based on Marlene Tahedl's BATMAN tutorial (http://www.miccai.org/edu/finalists/BATMAN_trimmed_tutorial.pdf)
# The main difference between this script and the other one in this repository, is that this script assumes that your diffusion images were acquired with AP phase encoding
# Thanks to John Plass and Bennet Fauber for useful comments

#display_usage() {
#	echo "$(basename $0) [Raw Diffusion] [RevPhaseImage] [AP bvec] [AP bval] [PA bvec] [PA bval] [Anatomical]"
#	echo "This script uses MRtrix to analyze diffusion data. It requires 7 arguments: 
#		1) The raw diffusion image;
#		2) The image acquired with the reverse phase-encoding direction;
#		3) The bvec file for the data acquired in the AP direction;
#		4) The bval file for the data acquired in the AP direction;
#		5) The bvec file for the data acquired in the PA direction;
#		6) The bval file for the data acquired in the PA direction;
#		7) The anatomical image"
#	}
#
#	if [ $# -le 6 ]
#	then
#		display_usage
#		exit 1
#	fi


# MRTRIX3_SHARE='/home/poolab/anaconda3/share/mrtrix3'
# VISTASOFT_HOME='/home/poolab/HeJieShi/DTI/Code/vistasoft-master'
source variable.sh
echo $MRTRIX3_SHARE
echo $VISTASOFT_HOME
RAW_DWI='./DTI.nii.gz'
# FIELDMAP=$2
# AP_BVEC=$3
# AP_BVAL=$4
AP_b0='./DTI_b0_AP.nii.gz'
PA_BVEC='./DTI.bvec'
PA_BVAL='./DTI.bval'
# subid='P_sub001'

ANAT='./T1w_acpc_dc_restore.nii.gz'


precentral_L='./ROIs/ROI_left_precentral.nii.gz'
precentral_R='./ROIs/ROI_right_precentral.nii.gz'

L_active_precentral_L='./ROIs/Activate_1e-3_left_finger_motor_left_precentral.nii.gz'
L_active_precentral_R='./ROIs/Activate_1e-3_left_finger_motor_right_precentral.nii.gz'
R_active_precentral_L='./ROIs/Activate_1e-3_right_finger_motor_left_precentral.nii.gz'
R_active_precentral_R='./ROIs/Activate_1e-3_right_finger_motor_right_precentral.nii.gz'

MNI_T1='./MNI152_T1_1mm.nii.gz'                    
MNI_rois="$VISTASOFT_HOME"/mrDiffusion/templates/MNI_JHU_tracts_ROIs
MNI_cst_L1="$VISTASOFT_HOME"/mrDiffusion/templates/MNI_JHU_tracts_ROIs/CST_roi1_L.nii.gz
MNI_cst_L2="$VISTASOFT_HOME"/mrDiffusion/templates/MNI_JHU_tracts_ROIs/CST_roi2_L.nii.gz
MNI_cst_R1="$VISTASOFT_HOME"/mrDiffusion/templates/MNI_JHU_tracts_ROIs/CST_roi1_R.nii.gz
MNI_cst_R2="$VISTASOFT_HOME"/mrDiffusion/templates/MNI_JHU_tracts_ROIs/CST_roi2_R.nii.gz

# MNI_cst_IC_L='/home/wy/MRI/DTI/AFQ/MRtrix_Analysis_Scripts-master/mrtrix_data/MNI_IC_postlimb_L.nii.gz'
# MNI_cst_IC_R='/home/wy/MRI/DTI/AFQ/MRtrix_Analysis_Scripts-master/mrtrix_data/MNI_IC_postlimb_R.nii.gz'

########################### STEP 1 ###################################
#	        Convert data to .mif format and denoise	   	     #
######################################################################

# 1 Also consider doing Gibbs denoising (using mrdegibbs). Check your diffusion data for ringing artifacts before deciding whether to use it
mrconvert $RAW_DWI raw_dwi.mif -fslgrad $PA_BVEC $PA_BVAL -force
dwidenoise raw_dwi.mif dwi_den.mif -noise noise.mif -force
# calculate the residual and check the quality
mrcalc raw_dwi.mif dwi_den.mif -subtract residual.mif -force
# 2 remove Gibbs ringing artifacts
mrdegibbs dwi_den.mif dwi_den_unr.mif -force

# Extract the b0 images from the diffusion data acquired in the PA direction
#dwiextract dwi_den.mif - -bzero | mrmath - mean mean_b0_AP.mif -axis 3
dwiextract dwi_den_unr.mif - -bzero | mrmath - mean mean_b0_PA.mif -axis 3 -force

# Extracts the b0 images for diffusion data acquired in the PA direction
# The term "fieldmap" is taken from the output from Michigan's fMRI Lab; it is not an actual fieldmap, but rather a collection of b0 images with both PA and AP phase encoding
# For the PA_BVEC and PA_BVAL files, they should be in the follwing format (assuming you extract only one volume):
# PA_BVEC: 0 0 0
# PA_BVAL: 0
#mrconvert $REV_PHASE PA.mif # If the PA map contains only 1 image, you will need to add the option "-coord 3 0"
#mrconvert PA.mif -fslgrad $PA_BVEC $PA_BVAL - | mrmath - mean mean_b0_PA.mif -axis 3

# creat b0 AP-PA pair
# transform  b0_AP.mif
mrconvert $AP_b0 - | mrmath - mean mean_b0_AP.mif -axis 3 -force
# Concatenates the b0 images from AP and PA directions to create a paired b0 image
mrcat mean_b0_PA.mif mean_b0_AP.mif -axis 3 b0_pair.mif  -force

# 3 Runs the dwipreproc command, which is a wrapper for eddy and topup. This step takes about 2 hours on an iMac desktop with 8 cores (3-4hours)
dwifslpreproc dwi_den_unr.mif dwi_den_preproc.mif -nocleanup -pe_dir PA -rpe_pair -se_epi b0_pair.mif -eddy_options " --slm=linear --data_is_shelled"   -force

# 4 Performs bias field correction. Needs ANTs to be installed in order to use the "ants" option (use "fsl" otherwise), yes or no?
dwibiascorrect ants dwi_den_preproc.mif dwi_den_preproc_unbiased.mif -bias bias.mif -force

# Create a mask for future processing steps,always have holls
# dwi2mask dwi_den_preproc_unbiased.mif mask.mif -force
# if has holls, check the mask has holls or not? you should mrview intact mask
##????? 
mrconvert dwi_den_preproc_unbiased.mif dwi_unbiased.nii -force
bet2 dwi_unbiased.nii dwi_masked -m -f 0.7     # 0.2-0.7 can be changed
mrconvert dwi_masked_mask.nii.gz mask.mif   -force

########################### STEP 2 ###################################
#            Create a GM/WM boundary for seed analysis               #
######################################################################

# 5 prepare for alignment to T1w
# The following series of commands will take the average of the b0 images (which have the best contrast), convert them and the 5tt image to NIFTI format, and use it for coregistration.
dwiextract dwi_den_preproc_unbiased.mif - -bzero | mrmath - mean mean_b0_processed.mif -axis 3 -force
mrconvert mean_b0_processed.mif mean_b0_processed.nii.gz -force
###################
# fsl produce the transform matrix in fsl format(no need force)
flirt.fsl -dof 6 -cost normmi -ref $ANAT -in mean_b0_processed.nii.gz -omat T_fsl.txt 
# transform fsl matrix format to mrtrix readable format
transformconvert T_fsl.txt mean_b0_processed.nii.gz $ANAT flirt_import T_DWItoT1.txt  -force
# use transform matrix to dwi coregister to T1
# mrtransform -linear T_DWItoT1.txt dwi_den_preproc_unbiased.mif dwi_coreg.mif -reorient_fod yes -force
mrtransform -linear T_DWItoT1.txt dwi_den_preproc_unbiased.mif dwi_coreg.mif -reorient_fod no -force


# 7 trajactory startpoint and endpoint
# Convert the anatomical image to .mif format, and then extract all five tissue catagories (1=GM; 2=Subcortical GM; 3=WM; 4=CSF; 5=Pathological tissue)
# mrconvert $subid/mri/aparc.a2009s+aseg.mgz aparc.a2009s+aseg.nii.gz
# 5ttgen freesurfer aparc.a2009s+aseg.nii.gz 5ttseg.mif -force # did not segment the lesion area
mrconvert $ANAT anat.mif  -force
5ttgen fsl anat.mif 5tt_nocoreg.mif -force # can segment the lesional area to csf

#Create a seed region along the GM/WM boundary
5tt2gmwmi 5tt_nocoreg.mif gmwmSeed_nocoreg.mif -force

########################### STEP 3 ###################################
#             Basis function for each tissue type                    #
######################################################################

# diffusion tensor imaging (optional)
# creat a mask 
dwi2mask dwi_coreg.mif - | maskfilter - dilate dwi_mask.mif -force
# creat diffusion tensor
dwi2tensor -mask dwi_mask.mif dwi_coreg.mif dt.mif -force
# calculate the FA MD RD AD
tensor2metric dt.mif -fa dt_fa.mif -ad dt_ad.mif -adc dt_md.mif -rd dt_rd.mif -force

### constrained spherical deconvolution(CSD) is the basis function!!!!!
# Create a basis function from the subject's DWI data. The "dhollander" function is best used for multi-shell acquisitions; it will estimate different basis functions for each tissue type. For single-shell acquisition, use the "tournier" function instead
# estimate response function for wm gm csf
dwi2response dhollander dwi_coreg.mif wm.txt gm.txt csf.txt -voxels voxels.mif -force

# dwi2response tournier dwi_coreg.mif wm.txt -voxels voxels.mif -force
# Performs multishell-multitissue constrained spherical deconvolution, using the basis functions estimated above(if two available b values, can only estimate wm and csf two tissues)
dwi2fod msmt_csd dwi_coreg.mif -mask mask.mif wm.txt wmfod.mif gm.txt gmfod.mif csf.txt csffod.mif -force
# use tournier
#dwi2fod csd dwi_coreg.mif -mask mask.mif wm.txt wmfod.mif -force

# Creates an image of the fiber orientation densities overlaid onto the estimated tissues (Blue=WM; Green=GM; Red=CSF)
# You should see FOD's mostly within the white matter. These can be viewed later with the command "mrview vf.mif -odf.load_sh wmfod.mif"
mrconvert -coord 3 0 wmfod.mif - | mrcat csffod.mif gmfod.mif - vf.mif -force

# estimate fiber orientation distribution FoD
dwi2fod msmt_csd dwi_coreg.mif \
         wm.txt wmcsd.mif \
         gm.txt gmcsd.mif \
         csf.txt csfcsd.mif

#dwi2fod csd dwi_coreg.mif \
         #wm.txt wmcsd.mif 

########################### STEP 4 ###################################
#                 Run the streamline analysis                        #
######################################################################

# Create streamlines

# ## transform MNI CST points into native T1w (ants), get prefix ants_ transform matrix
# # current folder ./ants_ (3hours)
antsRegistrationSyN.sh -d 3 -o ./ants \
      -f $ANAT -m $MNI_T1 -n 4
      
# # transform all_ROIs in MNI-space-AFQ to native roi
# # do not input d, it will output same dimention???no
# #for single_roi in ./*
# #do antsApplyTransforms -i $single_roi -r $ANAT -n GenericLabel -t /home/wy/MRI/DTI/AFQ/MRtrix_Analysis_Scripts-master/mrtrix_data/yhq_1/ants1Warp.nii.gz  -t /home/wy/MRI/DTI/AFQ/MRtrix_Analysis_Scripts-master/mrtrix_data/yhq_1/ants0GenericAffine.mat -o ana_$single_roi          
# #done



antsApplyTransforms -i $MNI_cst_L1 -r $ANAT -n GenericLabel -t ants1Warp.nii.gz  -t ants0GenericAffine.mat -o native_cst_L1.nii.gz
antsApplyTransforms -i $MNI_cst_L2 -r $ANAT -n GenericLabel -t ants1Warp.nii.gz  -t ants0GenericAffine.mat -o native_cst_L2.nii.gz
antsApplyTransforms -i $MNI_cst_R1 -r $ANAT -n GenericLabel -t ants1Warp.nii.gz  -t ants0GenericAffine.mat -o native_cst_R1.nii.gz
antsApplyTransforms -i $MNI_cst_R2 -r $ANAT -n GenericLabel -t ants1Warp.nii.gz  -t ants0GenericAffine.mat -o native_cst_R2.nii.gz

# antsApplyTransforms -i $MNI_cst_IC_L -r $ANAT -n GenericLabel -t ants1Warp.nii.gz  -t ants0GenericAffine.mat -o native_cst_IC_L.nii.gz
# antsApplyTransforms -i $MNI_cst_IC_R -r $ANAT -n GenericLabel -t ants1Warp.nii.gz  -t ants0GenericAffine.mat -o native_cst_IC_R.nii.gz
 
########################### STEP 5 ###################################
#                         connectome                                 #
######################################################################

# Note that the "right" number of streamlines is still up for debate. Last I read from the MRtrix documentation,
# They recommend about 100 million tracks. Here I use 10 million, if only to save time. Read their papers and then make a decision
### ROI-based tractography
# 6 freesurfer recon-all brain areas segmentation (about7-8hours) VIP!!!
# recon-all -i $ANAT -subjid $subid -sd . -all

### ROI-based tractography
# mrconvert $subid/mri/aparc.a2009s+aseg.mgz aparc.a2009s+aseg.nii.gz -force
#mri_extract_label -dilate 1 aparc.a2009s+aseg.nii.gz 192 Corpus_callosum.nii.gz
# mri_extract_label -dilate 1 aparc.a2009s+aseg.nii.gz 11111 lh_cenues.nii.gz
#mri_extract_label -dilate 1 aparc.a2009s+aseg.nii.gz 16 brain_stem.nii.gz
mri_extract_label -dilate 1 aparc.a2009s+aseg.nii.gz 11129  ctx_lh_G_precentral.nii.gz
mri_extract_label -dilate 1 aparc.a2009s+aseg.nii.gz 12129  ctx_rh_G_precentral.nii.gz  

# creat a mask
mrthreshold -abs 0.2 dt_fa.mif - | mrcalc - dwi_mask.mif -mult dwi_wmMask.mif -force
####### whole brain tractography (so many about 5-6hours??)
tckgen -algo iFOD2 -act 5tt_nocoreg.mif -backtrack -seed_gmwmi gmwmSeed_nocoreg.mif -seed_image dwi_wmMask.mif -nthreads 4 -nthreads 6 -minlength 20 -maxlength 250 -cutoff 0.06 -angle 45 -select 200K wmcsd.mif tracks_200k.tck -force

# Extract a subset of tracks (here, 200 thousand) for ease of visualization
tckedit tracks_200k.tck -number 200k smallerTracks_100k.tck -force

# Reduce the number of streamlines with tcksift
tcksift2 -act 5tt_nocoreg.mif -out_mu sift_mu.txt -out_coeffs sift_coeffs.txt -nthreads 8 smallerTracks_100k.tck wmcsd.mif sift_1M.txt -force

## connectome based on aparc2009
# relabel the parcellation
labelconvert aparc.a2009s+aseg.nii.gz $FREESURFER_HOME/FreeSurferColorLUT.txt \
             $MRTRIX3_SHARE/labelconvert/fs_a2009s.txt \
             aparc.a2009s+aseg_relabel.nii.gz -force
             
# generate a connetome by the volume by segmented brain area
tck2connectome -symmetric -zero_diagonal -scale_invnodevol \
               tracks_200k.tck \
               aparc.a2009s+aseg_relabel.nii.gz \
               connectome_a2009s.csv \
               -out_assignment assignments_a2009s.csv -force
               
 ###python draw metrix
 # can use the code named [connectome_matrix.ipynb] in python
 
 # mrview connectome 
 # mrview  aparc.a2009s+aseg_relabel.nii.gz -connectome.init \
         #aparc.a2009s+aseg_relabel.nii.gz -connectome.load connectome_a2009s.csv           
             
 
 ## generate a connectome by the fa mean
 tcksample tracks_200k.tck \
           dt_fa.mif tck_meanFA.txt -stat_tck mean -force 

 tck2connectome -symmetric -zero_diagonal \
                tracks_200k.tck \
                aparc.a2009s+aseg_relabel.nii.gz \
                connectome_fa.csv \
                -scale_file tck_meanFA.txt -stat_edge mean -force
 
 ###############################################################
 ###############################################################          
# MNI_CST_2areas coregister to individual T1
# # mannually_left_cst
# tckgen -algo iFOD2 -act 5tt_nocoreg.mif -cutoff 0.05 -angle 35 -nthreads 4 -minlength 20 -maxlength 250 -crop_at_gmwmi -seed_image native_cst_L1.nii.gz -include native_cst_IC_L.nii.gz  wmcsd.mif CST_left_mannual.tck -force

# # mannually_right_cst
# tckgen -algo iFOD2 -act 5tt_nocoreg.mif -cutoff 0.05 -angle 35 -nthreads 4 -minlength 20 -maxlength 250 -crop_at_gmwmi -seed_image native_cst_R1.nii.gz -include native_cst_IC_R.nii.gz  wmcsd.mif CST_right_mannual.tck -force

# # automated_left_cst
# tckgen -algo iFOD2 -act 5tt_nocoreg.mif -cutoff 0.05 -angle 35 -nthreads 4 -minlength 20 -maxlength 250 -crop_at_gmwmi -seed_image native_cst_L1.nii.gz -include native_cst_L2.nii.gz  wmcsd.mif CST_left_auto.tck -force
# # automated_right_cst
tckgen -algo iFOD2 -act 5tt_nocoreg.mif -cutoff 0.05 -angle 35 -nthreads 4 -minlength 20 -maxlength 250 -crop_at_gmwmi -seed_image native_cst_R1.nii.gz -include native_cst_R2.nii.gz wmcsd.mif CST_right_auto.tck -force

# ##### T1 precentral automated cst ##########
# # automated_left_cst_precentral
# tckgen -algo iFOD2 -act 5tt_nocoreg.mif -cutoff 0.05 -angle 35 -nthreads 4 -minlength 20 -maxlength 250 -crop_at_gmwmi -seed_image native_cst_L1.nii.gz -include $precentral_L  wmcsd.mif CST_left_precentral.tck -force
# # automated_right_cst_precentral
# tckgen -algo iFOD2 -act 5tt_nocoreg.mif -cutoff 0.05 -angle 35 -nthreads 4 -minlength 20 -maxlength 250 -crop_at_gmwmi -seed_image native_cst_R1.nii.gz -include $precentral_R  wmcsd.mif CST_right_precentral.tck -force

# # auto active CST_L(left hand grasp task)
# tckgen -algo iFOD2 -act 5tt_nocoreg.mif -cutoff 0.05 -angle 35 -nthreads 4 -minlength 20 -maxlength 250 -crop_at_gmwmi -seed_image native_cst_L1.nii.gz -include $L_active_precentral_L  -stop wmcsd.mif L_active_CST_L_1e-5.tck -force

# # auto active CST_R(left hand grasp task)
tckgen -algo iFOD2 -act 5tt_nocoreg.mif -cutoff 0.05 -angle 35 -nthreads 8 -minlength 20 -maxlength 250 -crop_at_gmwmi -seed_image native_cst_R1.nii.gz -include $L_active_precentral_R  -stop wmcsd.mif L_active_CST_R_1e-3.tck -force

# auto activate CST_L(right hand grasp task)
tckgen -algo iFOD2 -act 5tt_nocoreg.mif -cutoff 0.05 -angle 35 -nthreads 8 -minlength 20 -maxlength 250 -crop_at_gmwmi -seed_image  native_cst_L1.nii.gz -include $R_active_precentral_L  -stop  wmcsd.mif R_active_CST_L_1e-3.tck -force

# auto activate CST_R(right hand grasp task)
# tckgen -algo iFOD2 -act 5tt_nocoreg.mif -cutoff 0.05 -angle 35 -nthreads 8 -minlength 20 -maxlength 250 -crop_at_gmwmi -seed_image  native_cst_R1.nii.gz -include $R_active_precentral_R  -stop wmcsd.mif R_active_CST_R_1e-5.tck -force

## manually(need pre daw left_brainstem.nii.gz left_IC_postlimb.nii.gz CC_manual.nii.gz in ITK) total 5 rois
# manually_Left_CST
#tckgen -algo iFOD2 -act 5tt_nocoreg.mif -cutoff 0.05 -angle 35 -minlength 20 -maxlength 250 -crop_at_gmwmi -seed_image native_left_brainstem.nii.gz -include native_left_IC.nii.gz -exclude native_CC.nii.gz wmcsd.mif CST_left_mannual.tck -force

# manually_right_CST
# tckgen -algo iFOD2 -act 5tt_nocoreg.mif -cutoff 0.05 -angle 35 -minlength 20 -maxlength 250 -crop_at_gmwmi -seed_image native_right_brainstem.nii.gz -include native_right_IC.nii.gz -exclude native_CC.nii.gz wmcsd.mif CST_right_mannual.tck -force
 


