#!/bin/bash


# config Subject Afni_reslut_dir ME_sub StudyFolder
Subject=$1  # "SUB001" 
Afni_reslut_dir=$2  # /media/guoxl/data/wyStroke/AFNI/func_task/afni_result/$1.results  
Output_dir=$3  # /media/guoxl/data/wyStroke/AFNI/func_task/afni_result 
Afni_script=$4   # /media/guoxl/data/wyStroke/AFNI

# Subject="ME13"
StudyFolder=$5  # /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData_Pre
Subdir="$StudyFolder"/"$Subject"
ME_anat_dir="$StudyFolder"/"$Subject"/anat/T1w
ME_func_dir="$StudyFolder"/"$Subject"/func/rest/session_1/run_1


if [ ! -e "$Output_dir" ]; then
    mkdir "$Output_dir"
fi

# cp ./Coreg.sh "$Output_dir"/Coreg.sh
cp "$ME_anat_dir"/aparc+aseg.nii.gz "$Output_dir"/aparc+aseg.nii.gz 
cp "$ME_anat_dir"/T1w_acpc_dc_restore_brain.nii.gz "$Output_dir"/../T1w_acpc_dc_restore_brain.nii.gz 

# copy aparc+aseg.nii.gz from ME**
# if [ ! -e "$Output_dir"/Coreg.sh ]; then
#     echo "Coreg.sh does not exist!"
#     exit 1
# fi

if [ ! -e "$Output_dir"/aparc+aseg.nii.gz ]; then
    echo "aparc+aseg.nii.gz does not exist!"
    exit 1
fi



cd $Afni_reslut_dir
# convert to nifti
3dAFNItoNIFTI -prefix stats."$Subject"+orig.nii.gz stats."$Subject"+orig
3dAFNItoNIFTI -prefix mask_anat."$Subject"+orig.nii.gz mask_anat."$Subject"+orig

mv *.nii.gz $Output_dir

cd $Output_dir
# mask
fslmaths stats."$Subject"+orig.nii.gz -mas mask_anat."$Subject"+orig.nii.gz stats."$Subject".nii.gz
# extract t value
python3 "$Afni_script"/4Dto3D.py stats."$Subject".nii.gz
# align
# bash Coreg.sh

# resample to anat resolution
cp "$Afni_script"/resample_output.m ./resample_output.m
matlab -nodesktop -nosplash -r "resample_output; exit"
gzip tvalue_aligned_left_finger_motor.nii
gzip tvalue_aligned_right_finger_motor.nii
# cp ./output_3.nii.gz ./tvalue_aligned_left_finger_motor.nii.gz
# cp ./output_6.nii.gz ./tvalue_aligned_right_finger_motor.nii.gz
# extract roi-(tvalue_aligned.nii.gz)
cp "$Afni_script"/extract_roi_motor_finger.sh ./extract_roi_motor.sh
bash extract_roi_motor.sh
rm extract_roi_motor.sh


# mapping to surface
cd $Output_dir
tasks=(left_finger_motor right_finger_motor)

time3=$(date "+%Y-%m-%d %H:%M:%S") && echo "${time3} ------------------------Mapping Denoised Functional Data to Surface"
echo -e "Mapping Denoised Functional Data to Surface"

for task in "${tasks[@]}"
do
    # echo $task > /media/guoxl/data/wyStroke/AFNI/CiftiList_ROI.txt
    # to dtseries.nii.gz
    # 3dresample -dxyz 2 2 2 -inset tvalue_aligned_"$task".nii.gz -rmode Linear -prefix Reslice_tvalue_aligned_"$task".nii.gz
    ResampleImage 3 tvalue_aligned_"$task".nii.gz Reslice_tvalue_aligned_"$task".nii.gz 2x2x2 0 0
    # gzip Reslice_tvalue_aligned_"$task".nii
    cp Reslice_tvalue_aligned_"$task".nii.gz "$ME_func_dir"/Rest_"$task".nii.gz
    # bash /media/guoxl/data/wyStroke/AFNI/fMRI_wrapper_hjs.sh $StudyFolder $Subject 16 1 

    r=1
    s=1
    # define output dir for CIFTI creation;
    OUT_DIR="$Subdir"/func/rest/session_"$s"/run_"$r"

    for hemisphere in lh rh ; do

        # set a bunch of different 
        # ways of saying left and right
        if [ $hemisphere = "lh" ] ; then
            Hemisphere="L"
        elif [ $hemisphere = "rh" ] ; then
            Hemisphere="R"
        fi

        # define all of the the relevant surfaces & files;
        PIAL="$Subdir"/anat/T1w/Native/$Subject.$Hemisphere.pial.native.surf.gii
        WHITE="$Subdir"/anat/T1w/Native/$Subject.$Hemisphere.white.native.surf.gii
        MIDTHICK="$Subdir"/anat/T1w/Native/$Subject.$Hemisphere.midthickness.native.surf.gii
        MIDTHICK_FSLR32k="$Subdir"/anat/T1w/fsaverage_LR32k/$Subject.$Hemisphere.midthickness.32k_fs_LR.surf.gii
        ROI="$Subdir"/anat/MNINonLinear/Native/$Subject.$Hemisphere.roi.native.shape.gii
        ROI_FSLR32k="$Subdir"/anat/MNINonLinear/fsaverage_LR32k/$Subject.$Hemisphere.atlasroi.32k_fs_LR.shape.gii
        REG_MSMSulc="$Subdir"/anat/MNINonLinear/Native/$Subject.$Hemisphere.sphere.MSMSulc.native.surf.gii
        REG_MSMSulc_FSLR32k="$Subdir"/anat/MNINonLinear/fsaverage_LR32k/$Subject.$Hemisphere.sphere.32k_fs_LR.surf.gii

        # map functional data from volume to surface;
        wb_command -volume-to-surface-mapping "$OUT_DIR"/Rest_"$task".nii.gz "$MIDTHICK" \
        "$OUT_DIR"/"$hemisphere".native.shape.gii -ribbon-constrained "$WHITE" "$PIAL" 
    
        # dilate metric file 10mm in geodesic space;
        wb_command -metric-dilate "$OUT_DIR"/"$hemisphere".native.shape.gii \
        "$MIDTHICK" 10 "$OUT_DIR"/"$hemisphere".native.shape.gii -nearest

        # remove medial wall in native mesh;  
        wb_command -metric-mask "$OUT_DIR"/"$hemisphere".native.shape.gii \
        "$ROI" "$OUT_DIR"/"$hemisphere".native.shape.gii 

        # resample metric data from native mesh to fs_LR_32k mesh;
        wb_command -metric-resample "$OUT_DIR"/"$hemisphere".native.shape.gii "$REG_MSMSulc" \
        "$REG_MSMSulc_FSLR32k" ADAP_BARY_AREA "$OUT_DIR"/"$hemisphere".32k_fs_LR.shape.gii \
        -area-surfs "$MIDTHICK" "$MIDTHICK_FSLR32k" -current-roi "$ROI"

        # remove medial wall in fs_LR_32k mesh;
        wb_command -metric-mask "$OUT_DIR"/"$hemisphere".32k_fs_LR.shape.gii \
        "$ROI_FSLR32k" "$OUT_DIR"/"$hemisphere".32k_fs_LR.shape.gii

    done

    # combine hemispheres and subcortical structures into a single CIFTI file;
    tr=$(cat "$Subdir"/func/rest/session_"$s"/run_"$r"/TR.txt) # define the repitition time;
    # wb_command -cifti-create-dense-timeseries "$OUT_DIR"/Rest_"$task".dtseries.nii -volume "$Subdir"/func/rest/session_"$s"/run_"$r"/Rest_"$task".nii.gz "$Subdir"/func/rois/Subcortical_ROIs_acpc.nii.gz \
    # -left-metric "$OUT_DIR"/lh.32k_fs_LR.shape.gii -roi-left "$Subdir"/anat/MNINonLinear/fsaverage_LR32k/"$Subject".L.atlasroi.32k_fs_LR.shape.gii \
    # -right-metric "$OUT_DIR"/rh.32k_fs_LR.shape.gii -roi-right "$Subdir"/anat/MNINonLinear/fsaverage_LR32k/"$Subject".R.atlasroi.32k_fs_LR.shape.gii -timestep "$tr"
    
    wb_command -cifti-create-dense-timeseries "$OUT_DIR"/Rest_"$task".dtseries.nii -volume "$Subdir"/func/rest/session_"$s"/run_"$r"/Rest_"$task".nii.gz "$Subdir"/func/rois/Subcortical_ROIs_acpc.nii.gz \
    -left-metric "$OUT_DIR"/lh.32k_fs_LR.shape.gii -roi-left "$Subdir"/anat/MNINonLinear/fsaverage_LR32k/"$Subject".L.atlasroi.32k_fs_LR.shape.gii \
    -right-metric "$OUT_DIR"/rh.32k_fs_LR.shape.gii -roi-right "$Subdir"/anat/MNINonLinear/fsaverage_LR32k/"$Subject".R.atlasroi.32k_fs_LR.shape.gii -timestep "$tr"
    

    rm "$OUT_DIR"/*shape* # remove left over files 


done



