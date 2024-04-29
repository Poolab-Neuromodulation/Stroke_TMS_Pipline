#!/bin/bash

fslmaths tvalue_aligned.nii.gz -thr 3.3 -bin -mul tvalue_aligned.nii.gz tmp_1e-3.nii.gz
fslmaths tvalue_aligned.nii.gz -thr 4.45 -bin -mul tvalue_aligned.nii.gz tmp_1e-5.nii.gz

# 列表
idxs=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23)
labels=(1003 1027 1028 1018 1019 1020 1024 1031 1008 1009 1015 1030 1034 2003 2027 2028 2018 2019 2020 2024 2031 2008 2009 2015 2030 2034)
names=(ctx_lh_caudalmiddlefrontal ctx_lh_rostralmiddlefrontal ctx_lh_superiorfrontal ctx_lh_parsopercularis ctx_lh_parsorbitalis ctx_lh_parstriangularis ctx_lh_precentral ctx_lh_supramarginal ctx_lh_inferiorparietal ctx_lh_inferiortemporal ctx_lh_middletemporal ctx_lh_superiortemporal ctx_lh_transversetemporal \
ctx_rh_caudalmiddlefrontal ctx_rh_rostralmiddlefrontal ctx_rh_superiorfrontal ctx_rh_parsopercularis ctx_rh_parsorbitalis ctx_rh_parstriangularis ctx_rh_precentral ctx_rh_supramarginal ctx_rh_inferiorparietal ctx_rh_inferiortemporal ctx_rh_middletemporal ctx_rh_superiortemporal ctx_rh_transversetemporal)

mkdir ROIs
# 循环取值并执行命令
for i in "${idxs[@]}"
do
    mri_extract_label aparc+aseg.nii.gz ${labels[i]} ./ROIs/ROI_${names[i]}.nii.gz
    fslmaths tmp_1e-3.nii.gz -mas ./ROIs/ROI_${names[i]}.nii.gz ./ROIs/Activate_1e-3_${names[i]}.nii.gz
    fslmaths tmp_1e-5.nii.gz -mas ./ROIs/ROI_${names[i]}.nii.gz ./ROIs/Activate_1e-5_${names[i]}.nii.gz
    # echo ${labels[i]}
    # echo "Processing ${names[i]}"
    # mri_extract_label -l "$i" -roi input.mgz "$i.nii.gz"
done

cd ROIs
# merge IFG ROI
fslmaths ROI_ctx_lh_parsopercularis.nii.gz -add ROI_ctx_lh_parsorbitalis.nii.gz -add ROI_ctx_lh_parstriangularis.nii.gz ROI_ctx_lh_IFG.nii.gz
fslmaths ROI_ctx_rh_parsopercularis.nii.gz -add ROI_ctx_rh_parsorbitalis.nii.gz -add ROI_ctx_rh_parstriangularis.nii.gz ROI_ctx_rh_IFG.nii.gz

fslmaths Activate_1e-3_ctx_lh_parsopercularis.nii.gz -add Activate_1e-3_ctx_lh_parsorbitalis.nii.gz -add Activate_1e-3_ctx_lh_parstriangularis.nii.gz Activate_1e-3_ctx_lh_IFG.nii.gz
fslmaths Activate_1e-3_ctx_rh_parsopercularis.nii.gz -add Activate_1e-3_ctx_rh_parsorbitalis.nii.gz -add Activate_1e-3_ctx_rh_parstriangularis.nii.gz Activate_1e-3_ctx_rh_IFG.nii.gz

fslmaths Activate_1e-5_ctx_lh_parsopercularis.nii.gz -add Activate_1e-5_ctx_lh_parsorbitalis.nii.gz -add Activate_1e-5_ctx_lh_parstriangularis.nii.gz Activate_1e-5_ctx_lh_IFG.nii.gz
fslmaths Activate_1e-5_ctx_rh_parsopercularis.nii.gz -add Activate_1e-5_ctx_rh_parsorbitalis.nii.gz -add Activate_1e-5_ctx_rh_parstriangularis.nii.gz Activate_1e-5_ctx_rh_IFG.nii.gz

cd ..
zip -r ROIs.zip ROIs 


# extracting label 1003 (ctx_lh_caudalmiddlefrontal)
# extracting label 1027 (ctx_lh_rostralmiddlefrontal)
# extracting label 1028 (ctx_lh_superiorfrontal)
# extracting label 1018 (ctx_lh_parsopercularis)
# extracting label 1019 (ctx_lh_parsorbitalis)
# extracting label 1020 (ctx_lh_parstriangularis)
# extracting label 1024 (ctx_lh_precentral)
# extracting label 1031 (ctx_lh_supramarginal)
# extracting label 1008 (ctx_lh_inferiorparietal)
# extracting label 1009 (ctx_lh_inferiortemporal)
# extracting label 1015 (ctx_lh_middletemporal)
# extracting label 1030 (ctx_lh_superiortemporal)
# extracting label 1034 (ctx_lh_transversetemporal)
# extracting label 2003 (ctx_rh_caudalmiddlefrontal)
# extracting label 2027 (ctx_rh_rostralmiddlefrontal)
# extracting label 2028 (ctx_rh_superiorfrontal)
# extracting label 2018 (ctx_rh_parsopercularis)
# extracting label 2019 (ctx_rh_parsorbitalis)
# extracting label 2020 (ctx_rh_parstriangularis)
# extracting label 2024 (ctx_rh_precentral)
# extracting label 2031 (ctx_rh_supramarginal)
# extracting label 2008 (ctx_rh_inferiorparietal)
# extracting label 2009 (ctx_rh_inferiortemporal)
# extracting label 2015 (ctx_rh_middletemporal)
# extracting label 2030 (ctx_rh_superiortemporal)
# extracting label 2034 (ctx_rh_transversetemporal)
