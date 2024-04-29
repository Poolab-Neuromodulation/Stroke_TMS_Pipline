antsRegistrationSyN.sh -d 3 -o ./ants \
    -t a -n 16 \
    -f ../T1w_acpc_dc_restore_brain.nii.gz \
    -m ../brain.nii.gz

antsApplyTransforms -d 3 \
    -i ./output_3.nii.gz \
    -r ../T1w_acpc_dc_restore_brain.nii.gz \
    -n BSpline \
    -t ./ants0GenericAffine.mat \
    -o ./tvalue_aligned_left_finger_motor.nii.gz
#     -t ./ants1Warp.nii.gz \

antsApplyTransforms -d 3 \
    -i ./output_6.nii.gz \
    -r ../T1w_acpc_dc_restore_brain.nii.gz \
    -n BSpline \
    -t ./ants0GenericAffine.mat \
    -o ./tvalue_aligned_right_finger_motor.nii.gz
#     -t ./ants1Warp.nii.gz \
