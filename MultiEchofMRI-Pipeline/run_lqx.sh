bash anat_highres_HCP_wrapper_par.sh /home/poolab/HeJieShi/Health_data ME13 16 2>&1 | tee -i ./log/anat_highres_HCP_wrapper_par_0226.log

bash func_preproc+denoise_ME-fMRI_wrapper_hjs.sh /home/poolab/HeJieShi/Health_data ME13 16 1 2>&1 | tee -i ./log/func_preproc+denoise_ME-fMRI_wrapper_hjs_0226.log

