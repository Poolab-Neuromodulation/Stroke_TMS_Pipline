#!/bin/bash

fslmaths tvalue_aligned_left_finger_motor.nii.gz -thr 3.3 -bin -mul tvalue_aligned_left_finger_motor.nii.gz tmp_1e-3_left_finger_motor.nii.gz
fslmaths tvalue_aligned_left_finger_motor.nii.gz -thr 4.45 -bin -mul tvalue_aligned_left_finger_motor.nii.gz tmp_1e-5_left_finger_motor.nii.gz
fslmaths tvalue_aligned_right_finger_motor.nii.gz -thr 3.3 -bin -mul tvalue_aligned_right_finger_motor.nii.gz tmp_1e-3_right_finger_motor.nii.gz
fslmaths tvalue_aligned_right_finger_motor.nii.gz -thr 4.45 -bin -mul tvalue_aligned_right_finger_motor.nii.gz tmp_1e-5_right_finger_motor.nii.gz

# 列表
idxs=(0 1 2 3)
labels=(1024 2024 1022 2022)
names=(left_precentral right_precentral left_postcentral right_postcentral)

mkdir ROIs
# 循环取值并执行命令
for i in "${idxs[@]}"
do
    mri_extract_label aparc+aseg.nii.gz ${labels[i]} ./ROIs/ROI_${names[i]}.nii.gz
    fslmaths tmp_1e-3_left_finger_motor.nii.gz -mas ./ROIs/ROI_${names[i]}.nii.gz ./ROIs/Activate_1e-3_left_finger_motor_${names[i]}.nii.gz
    fslmaths tmp_1e-5_left_finger_motor.nii.gz -mas ./ROIs/ROI_${names[i]}.nii.gz ./ROIs/Activate_1e-5_left_finger_motor_${names[i]}.nii.gz
    fslmaths tmp_1e-3_right_finger_motor.nii.gz -mas ./ROIs/ROI_${names[i]}.nii.gz ./ROIs/Activate_1e-3_right_finger_motor_${names[i]}.nii.gz
    fslmaths tmp_1e-5_right_finger_motor.nii.gz -mas ./ROIs/ROI_${names[i]}.nii.gz ./ROIs/Activate_1e-5_right_finger_motor_${names[i]}.nii.gz

    fslmaths ./ROIs/Activate_1e-3_left_finger_motor_${names[i]}.nii.gz -thr 0 -bin ./ROIs/Activate_1e-3_left_finger_motor_${names[i]}.ROI.nii.gz
    fslmaths ./ROIs/Activate_1e-5_left_finger_motor_${names[i]}.nii.gz -thr 0 -bin ./ROIs/Activate_1e-5_left_finger_motor_${names[i]}.ROI.nii.gz
    fslmaths ./ROIs/Activate_1e-3_right_finger_motor_${names[i]}.nii.gz -thr 0 -bin ./ROIs/Activate_1e-3_right_finger_motor_${names[i]}.ROI.nii.gz
    fslmaths ./ROIs/Activate_1e-5_right_finger_motor_${names[i]}.nii.gz -thr 0 -bin ./ROIs/Activate_1e-5_right_finger_motor_${names[i]}.ROI.nii.gz
    # echo ${labels[i]}
    # echo "Processing ${names[i]}"
    # mri_extract_label -l "$i" -roi input.mgz "$i.nii.gz"
done

zip -r ROIs.zip ROIs 
