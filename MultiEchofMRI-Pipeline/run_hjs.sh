bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME01 16

bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME01 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0402.log

applywarp --interp=spline --in=/home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData/ME01/func/rest/session_1/run_1/SBref.nii.gz --ref=/home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/MultiEchofMRI-Pipeline/res0urces/FSL/MNI152_T1_2mm.nii.gz --out=/home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData/ME01/func/xfms/rest/SBref2acpc_EpiReg_S1_R1.nii.gz --warp=/home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData/ME01/func/xfms/rest/SBref2acpc_EpiReg_S1_R1_warp.nii.gz

/home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/MultiEchofMRI-Pipeline/func_preproc_headmotion.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/MultiEchofMRI-Pipeline ME01 /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/MultiEchofMRI-Pipeline/res0urces/FSL/MNI152_T1_2mm.nii.gz 6 16 1

/home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/MultiEchofMRI-Pipeline/func_denoise_meica.sh ME01 /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData 16 kundu 500 5 1

tedana -d /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData/ME01/func/rest/session_1/run_1/Rest_E1_acpc.nii.gz /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData/ME01/func/rest/session_1/run_1/Rest_E2_acpc.nii.gz /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData/ME01/func/rest/session_1/run_1/Rest_E3_acpc.nii.gz /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData/ME01/func/rest/session_1/run_1/Rest_E4_acpc.nii.gz -e 15.1 28.7 42.3 55.9 --out-dir /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData/ME01/func/rest/session_1/run_1/Tedana/ --tedpca kundu --fittype curvefit --mask /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData/ME01/func/rest/session_1/run_1/brain_mask.nii.gz --maxit 500 --maxrestart 5 --seed 42

### new 0404
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME01 16 | tee -i ./log/anat_hjs_0404.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME01 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0404.log

bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME01 4 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0406.log

### new wy_data
conda activate tedana_v10
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME01 16 | tee -i ./log/anat_hjs_0414.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME01 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0414.log

## xuzhiiiiiiiwei_cut
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME11 16 | tee -i ./log/anat_hjs_0903.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME11 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0903.log

## guxinyi_cut
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME02 16 | tee -i ./log/anat_hjs_0904.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME02 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0904.log

bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME02 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0904.log

# rerun_wy_ME01
bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /data/wy_stroke/ExampleData ME01 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0905_ME01_wy.log

# dinghuanhuan
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME12 16 | tee -i ./log/anat_hjs_0903.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME12 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0906_dinghuanhuan.log
bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME12 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0908_dinghuanhuan.log

# vol2surf
conda activate tedana_v10
bash fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME04 16 1 

# yanhongqing 04 run2
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData_run2 ME04 16 | tee -i ./log/anat_hjs_0929_yanhongqing.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME04 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0929_yanhongqing.log
bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData_run2 ME04 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_1004_yanhongqing_run2.log



# luomeifang 07 run1
conda activate tedana_v10
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME07 16 | tee -i ./log/anat_hjs_1014_luomeifang.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME07 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_1014_luomeifang.log

# hejieshi 13 run1
conda activate tedana_v10
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME13 16 | tee -i ./log/anat_hjs_1018_hejieshi.log 

# luomeifang 07 run2
conda activate tedana_v10
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME07 16 | tee -i ./log/anat_hjs_1031_luomeifang_run2.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME07 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_1031_luomeifang_run2.log


# wangying 01 wangying_20230413
conda activate tedana_v10
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME01 16 | tee -i ./log/anat_hjs_1113_wangying.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME01 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_1113_wangying.log


# fanjun 08 20231122 run1
conda activate tedana_v10
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME08 16 | tee -i ./log/anat_hjs_1122_fanjun.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME08 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_1122_fanjun.log


conda activate tedana_v10
bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME14 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_1125_xirunhai_from_wypc.log


# fanjun 08 20231206 run2
conda activate tedana_v10
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData_run2 ME08 16 | tee -i ./log/anat_hjs_1206_fanjun_run2.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData_run2 ME08 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_1206_fanjun_run2.log


# sub015  zhengjie run1
conda activate tedana_v10
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME15 16 | tee -i ./log/anat_hjs_1208_zhengjie_run1.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME15 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_1208_zhengjie_run1.log

# xirunhai sub014 run2
conda activate tedana_v10
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData_run2 ME14 16 | tee -i ./log/anat_hjs_1213_xirunhai_run2.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData_run2 ME14 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_1213_xirunhai_run2.log

# dongrongrong sub016 run2
conda activate tedana_v10
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData_run2 ME16 16 | tee -i ./log/anat_hjs_1221_dongrongrong_run2.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData_run2 ME16 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_1221_dongrongrong_run2.log

# sub015  zhengjie run2
conda activate tedana_v10
bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData_run2 ME15 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_1223_zhengjie_run2.log


# sub017  luoxinmin run1
conda activate tedana_v10
bash anat_highres_HCP_wrapper_par.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME17 16 | tee -i ./log/anat_hjs_0105_luoxinmin_run1.log && bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData ME17 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0105_luoxinmin_run1.log
