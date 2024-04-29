import os
from tarfile import TarError
import time
import json
import config
from ME_format_transform import FormatTransformer
from regressor import motion_regressor, csf_wm_regressor, physiology_regressor_split, combine_all_regressor

class rsfMRIProcessor:
    def __init__(self, multi_echo=True, n_thread=16):
        self.run_time = time.strftime("%Y%m%d", time.localtime())
        self.log_dir = config.LOG_DIR
        self.raw_dir = config.DATA_CONFIG['source']
        self.script_dir = config.SCRIPTS_CONFIG['MultiEcho']
        self.hcp_dir = config.SCRIPTS_CONFIG['HCPPipline']
        self.pfm_script_dir = config.SCRIPTS_CONFIG['PFM']
        self.tans_script_dir = config.SCRIPTS_CONFIG['TANS']
        self.data_dir = config.DATA_CONFIG['root']
        self.subj_id = config.DATA_CONFIG['subject_id']
        self.simnibs_ld_dir = config.SIMNIBS_CONFIG['LD_LIBRARY']
        self.simnibs_dir = config.SIMNIBS_CONFIG['root']
        self.sub_dir = os.path.join(self.data_dir, self.subj_id)
        self.multi_echo = multi_echo
        self.n_thread = n_thread

    def format_transform(self, t1_pattern=r't1', t2_pattern=r't2', fm_pattern=r'fieldmap', me_pattern=r'me', echo_pattern=r'Echo\d', echo1_pattern=r'Echo1', echo2_pattern=r'Echo2', b0map_pattern=r'B0Map', dti_pattern=r'dti', ap_pattern=r'AP', pa_pattern=r'PA', task_pattern=r'task_SaveBySlc', bold_pattern=r'se10min_SaveBySlc'):
        ft = FormatTransformer(self.raw_dir, self.data_dir, subj_id=self.subj_id)
        if self.multi_echo:
            ft.multi_echo_format(t1_pattern=t1_pattern, t2_pattern=t2_pattern, fm_pattern=fm_pattern, me_pattern=me_pattern, echo_pattern=echo_pattern, echo1_pattern=echo1_pattern, echo2_pattern=echo2_pattern, b0map_pattern=b0map_pattern, dti_pattern=dti_pattern, ap_pattern=ap_pattern, pa_pattern=pa_pattern, task_pattern=task_pattern)
        else:
            ft.single_echo_format(t1_pattern=t1_pattern, t2_pattern=t2_pattern, fm_pattern=fm_pattern, echo1_pattern=echo1_pattern, echo2_pattern=echo2_pattern, b0map_pattern=b0map_pattern, dti_pattern=dti_pattern, ap_pattern=ap_pattern, pa_pattern=pa_pattern, task_pattern=task_pattern, bold_pattern=bold_pattern)


    def anat_pipline(self):    
        os.system(f'bash {self.script_dir}/anat_highres_HCP_wrapper_par.sh {self.data_dir} {self.subj_id} {self.n_thread} 2>&1 | tee -i {self.log_dir}/{self.subj_id}_anat_{self.run_time}.log')

    def multi_echo_pipline(self):
        os.system(f'bash {self.script_dir}/func_preproc+denoise_ME-fMRI_wrapper_hjs.sh {self.data_dir} {self.subj_id} {self.n_thread} 1 2>&1 | tee -i {self.log_dir}/{self.subj_id}_me_func_{self.run_time}.log')

    def single_echo_pipline(self):
        fmriprep_dir = os.path.join(self.sub_dir, 'fmriprep_result')
        fmriprep_out_dir = os.path.join(self.sub_dir, 'fmriprep_result/derivatives')
        fmriprep_tmp_dir = os.path.join(self.sub_dir, 'work')
        os.system(f'cp {self.sub_dir}/anat/T1w/T1w_acpc_dc_restore.nii.gz {self.sub_dir}/fmriprep_result/sub-{self.subj_id}/anat/sub-{self.subj_id}_T1w.nii.gz')
        # 2. fmriprep
        os.system(f'fmriprep {fmriprep_dir} {fmriprep_out_dir} participant --participant-label {self.subj_id} --skip-bids-validation  --md-only-boilerplate  --stop-on-first-crash  --fs-no-reconall  --output-spaces T1w  -w {fmriprep_tmp_dir}')
        # 3. denoise
        os.system(f'gzip -d {fmriprep_out_dir}/sub-{self.subj_id}/func/sub-{self.subj_id}_task-rest_space-T1w_desc-preproc_bold.nii.gz')
        os.system(f'gzip -d {fmriprep_out_dir}/sub-{self.subj_id}/func/sub-{self.subj_id}_task-rest_space-T1w_desc-brain_mask.nii.gz')
        tsv = f'{fmriprep_out_dir}/sub-{self.subj_id}/func/sub-{self.subj_id}_task-rest_desc-confounds_timeseries.tsv'
        confond = f'{fmriprep_out_dir}/sub-{self.subj_id}/func/sub-{self.subj_id}_task-rest_desc-confounds_timeseries.json'
        bold = f'{fmriprep_out_dir}/sub-{self.subj_id}/func/sub-{self.subj_id}_task-rest_space-T1w_desc-preproc_bold.nii'
        mask = f'{fmriprep_out_dir}/sub-{self.subj_id}/func/sub-{self.subj_id}_task-rest_space-T1w_desc-brain_mask.nii'
        
        
        clean_data = f'{fmriprep_out_dir}/sub-{self.subj_id}/func/clean_data.nii'
        single_echo_data = f'{self.sub_dir}/func/rest/session_1/run_1/Rest_OCME+MEICA.nii.gz'

        motion_regressor(tsv, 'motion_regressor.mat')
        csf_wm_regressor(tsv, confond, 'csf_wm_regressor.mat')
        os.system(f'matlab -nodesktop -nosplash -r \"n_PCA=pca_volume(\'{bold}\',\'{mask}\',\'pca.mat\',0,0.005,50);exit\"')
        physiology_regressor_split('pca.mat',[50])
        combine_all_regressor(['motion_regressor.mat', 'csf_wm_regressor.mat', 'pca.mat'], 'all_regressor.mat')
        os.system(f'matlab -nodesktop -nosplash -r \"nuisance_regressout_volume(\'{bold}\', \'all_regressor.mat\', \'{clean_data}\');exit\"')
        os.system('rm motion_regressor.mat')
        os.system('rm csf_wm_regressor.mat')
        os.system('rm pca.mat')
        os.system('rm all_regressor.mat')   
        
        if not os.path.exists(f'{self.sub_dir}/func/rest/session_1/run_1'):
            os.makedirs(f'{self.sub_dir}/func/rest/session_1/run_1')
            os.makedirs(f'{self.sub_dir}/func/xfms/rest')
            os.makedirs(f'{self.sub_dir}/func/qa')

        os.system(f'mcflirt -dof 6 -stages 3 -plots -in {clean_data} -out {self.sub_dir}/func/rest/session_1/run_1/MCF')
        os.system(f'flirt -interp nearestneighbour -in {self.sub_dir}/anat/T1w/T1w_acpc_brain_mask.nii.gz -ref {self.script_dir}/res0urces/FSL/MNI152_T1_2mm.nii.gz -out {self.sub_dir}/func/xfms/rest/T1w_acpc_brain_func_mask.nii.gz -applyxfm -init {self.script_dir}/res0urces/ident.mat')
        os.system(f'fslinfo {clean_data} | grep pixdim4 >> tmp.txt')
        os.system(f'sed \'s/pixdim4\\s*//\' tmp.txt | grep [0-9]*\\.[0-9]* > {self.sub_dir}/func/rest/session_1/run_1/TR.txt')
        os.system('rm tmp.txt')
        os.system(f'bash bold_resample.sh {fmriprep_out_dir}/sub-{self.subj_id}/func {self.sub_dir}/func/xfms/rest/T1w_acpc_brain_func_mask.nii.gz {single_echo_data}') 
        os.system(f'bash {self.script_dir}/se_func_denoise_mgtr.sh {self.subj_id} {self.data_dir} {self.script_dir}')
        os.system(f'bash {self.script_dir}/func_vol2surf.sh {self.subj_id} {self.data_dir} {self.script_dir} {self.script_dir}/config/fmriprep_list.txt 1')


    def pfm(self):
        os.system(f'rm -rf {self.sub_dir}/workspace/ > /dev/null 2>&1')
        os.system(f'mkdir {self.sub_dir}/workspace/ > /dev/null 2>&1')
        if self.multi_echo:
            os.system(f'cp -rf {self.pfm_script_dir}/pfm_use.m {self.sub_dir}/workspace/temp.m')
        else:
            os.system(f'cp -rf {self.pfm_script_dir}/pfm_use_se.m {self.sub_dir}/workspace/temp.m')

        # define matlab variables
        # resources_dir = os.path.join(self.script_dir, '')
        os.system(f'echo Subdir = \\\'{self.sub_dir}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')
        os.system(f'echo nThreads = {self.n_thread} | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')
        current_dir = os.getcwd()
        os.chdir(os.path.join(self.sub_dir, 'workspace'))
        os.system(f'matlab -nodesktop -nosplash -r \"temp; exit\"')
        os.system(f'rm {self.sub_dir}/workspace/temp.m')
        os.chdir(current_dir)


    def tans(self, dense_idx, M1_cluster_idx, S1_cluster_idx, hemi):
        os.system(f'rm -rf {self.sub_dir}/workspace/ > /dev/null 2>&1')
        os.system(f'mkdir {self.sub_dir}/workspace/ > /dev/null 2>&1')
        os.system(f'cp -rf {self.tans_script_dir}/tans_use.m {self.sub_dir}/workspace/temp.m')

        os.system(f'echo SimNIBS_LD_PATH = \\\'{self.simnibs_ld_dir}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')
        os.system(f'echo Paths{{1}} = \\\'{self.simnibs_dir}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')
        os.system(f'echo DataDir = \\\'{self.data_dir}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')
        os.system(f'echo Subject = \\\'{self.subj_id}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')     
        os.system(f'echo dense_idx = {dense_idx} | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')          
        os.system(f'echo M1_cluster_idx = {M1_cluster_idx} | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ') 
        os.system(f'echo S1_cluster_idx = {S1_cluster_idx} | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ') 
        os.system(f'echo hemi = \\\'{hemi}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ') 
        os.system(f'echo nThreads = {self.n_thread} | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')

        current_dir = os.getcwd()
        os.chdir(os.path.join(self.sub_dir, 'workspace'))
        os.system(f'matlab -nodesktop -nosplash -r \"temp; exit\"')
        os.system(f'rm {self.sub_dir}/workspace/temp.m')
        os.chdir(current_dir)

    def tans_head_model(self):
        os.system(f'rm -rf {self.sub_dir}/workspace/ > /dev/null 2>&1')
        os.system(f'mkdir {self.sub_dir}/workspace/ > /dev/null 2>&1')
        os.system(f'cp -rf {self.tans_script_dir}/tans_headmodel_use.m {self.sub_dir}/workspace/temp.m')

        os.system(f'echo SimNIBS_LD_PATH = \\\'{self.simnibs_ld_dir}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')
        os.system(f'echo Paths{{1}} = \\\'{self.simnibs_dir}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')
        os.system(f'echo DataDir = \\\'{self.data_dir}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')
        os.system(f'echo Subject = \\\'{self.subj_id}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')     

        current_dir = os.getcwd()
        os.chdir(os.path.join(self.sub_dir, 'workspace'))
        os.system(f'matlab -nodesktop -nosplash -r \"temp; exit\"')
        os.system(f'rm {self.sub_dir}/workspace/temp.m')
        os.chdir(current_dir)



    def run(self):
        self.anat_pipline()
        if self.multi_echo:
            self.multi_echo_pipline()
        else:
            self.single_echo_pipline()
        self.pfm()


class taskfMRIProcessor:
    def __init__(self):
        self.delay = config.TASK_FMRI_CONFIG['delay']
        self.log_dir = config.LOG_DIR
        self.subj_id = config.DATA_CONFIG['subject_id']
        self.study_folder = config.DATA_CONFIG['root']
        self.task_script_dir = config.TASK_FMRI_CONFIG['script']
        self.task_dir = os.path.join(config.DATA_CONFIG['root'], self.subj_id, 'func_task')
        self.anat_path = os.path.join(config.DATA_CONFIG['root'], self.subj_id, 'anat/T1w/T1w_acpc_dc_restore_brain.nii.gz')
        self.dsets = os.path.join(self.task_dir, 'unprocessed/bold_task_hand_motor.nii.gz')
        self.stim_times_left = os.path.join(self.task_dir, 'unprocessed/Motor_left.txt')
        self.stim_times_right = os.path.join(self.task_dir, 'unprocessed/Motor_right.txt')
        self.task_fmri_work_dir = os.path.join(self.task_dir, 'afni_result')
        self.cmd_ap = os.path.join(self.task_script_dir, 'cmd.ap')
        self.slice_timing = os.path.join(self.task_dir, 'unprocessed/SliceTiming.1D')

    def write_slice_timing(self):
        with open(f'{self.task_dir}/unprocessed/bold_task_hand_motor.json', 'r') as f:
            data = json.load(f)
        slicetiming = data["SliceTiming"]
        text = '\n3drefit -Tslices '
        for i in range(len(slicetiming)):
            text += str(slicetiming[i]) + ' '
        text += 'pb00.$subj.r01.tcat+orig' 
        with open(self.slice_timing, 'w+') as f:
            f.write(text)

    def write_stim_times(self, delay):
        left = [20, 64, 108, 284, 328, 372, 416]
        right = [152, 196, 240, 460, 504, 548, 592]
        stim_left = [i + delay for i in left]
        stim_right = [i + delay for i in right]

        left_text = ''
        right_text = ''
        for i in range(len(stim_left)):
            left_text += str(stim_left[i]) + ' '
            right_text += str(stim_right[i]) + ' '

        with open(self.stim_times_left, 'w+') as f:
            f.write(left_text)
        with open(self.stim_times_right, 'w+') as f:
            f.write(right_text)

    def run(self):
        # if not os.path.exists(os.path.join(self.task_dir, 'unprocessed')):
        #     os.makedirs(os.path.join(self.task_dir, 'unprocessed'))
        self.write_slice_timing()
        self.write_stim_times(self.delay)

        os.system(f'cp {self.anat_path} {self.task_dir}/unprocessed')
        self.anat_path = os.path.join(self.task_dir, 'unprocessed/T1w_acpc_dc_restore_brain.nii.gz')
        current_dir = os.getcwd()
        os.chdir(self.task_fmri_work_dir)
        os.system(f'cp {self.cmd_ap} ./')
        os.system(f'tcsh ./cmd.ap {self.subj_id} {self.anat_path} {self.dsets} {self.stim_times_left} {self.stim_times_right}')
    
        new_lines = []
        with open(f'proc.{self.subj_id}', 'r') as f:
            for line in f.readlines():
                # if line.strip() == '# QC: look for columns of high variance':
                if line.strip() == '# ========================== auto block: outcount ==========================':
                    new_lines.append(open(self.slice_timing, 'r').read())
                    # new_lines.append('exit\n')
                new_lines.append(line)
        with open(f'proc.{self.subj_id}', 'w') as f:
            f.writelines(new_lines)

        os.system(f'tcsh -xef proc.{self.subj_id} 2>&1 | tee {self.log_dir}/output.proc.{self.subj_id}')
        os.chdir(current_dir)


        # afni postprocess
        afni_result_dir = f'{self.task_dir}/afni_result/{self.subj_id}.results'
        output_dir = f'{self.task_dir}/activate_roi'
        os.system(f'bash {self.task_script_dir}/afni_postprocess.sh {self.subj_id} {afni_result_dir} {output_dir} {self.task_script_dir} {self.study_folder} 2>&1 | tee {self.log_dir}/afni_postprocess.sh.{self.subj_id}.log')


class DTIProcessor:
    def __init__(self):
        self.data_dir = config.DATA_CONFIG['root']
        self.log_dir = config.LOG_DIR
        self.subj_id = config.DATA_CONFIG['subject_id']
        self.dti_script = os.path.join(config.DTI_CONFIG['script'], '01_MRtrix_Preproc_AP_Direction_final.sh')
        self.mrtrix3 = config.DTI_CONFIG['MRTRIX3_SHARE']
        self.vistasoft = config.DTI_CONFIG['VISTASOFT']
        self.hcp_dir = config.SCRIPTS_CONFIG['HCPPipline']
        self.sub_dir = os.path.join(self.data_dir, self.subj_id)
        self.dti_dir = os.path.join(self.sub_dir, 'dti')

    def get_target(self, cluster_idx, hemi='rh'):
        target_script = os.path.join(config.DTI_CONFIG['script'], 'fiber_in_cluster.m')
        os.system(f'rm -rf {self.sub_dir}/workspace/ > /dev/null 2>&1')
        os.system(f'mkdir {self.sub_dir}/workspace/ > /dev/null 2>&1')
        os.system(f'cp -rf {target_script} {self.sub_dir}/workspace/temp.m')

        os.system(f'echo DataDir = \\\'{self.data_dir}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')
        os.system(f'echo Subject = \\\'{self.subj_id}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')        
        os.system(f'echo hemi = \\\'{hemi}\\\' | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')
        os.system(f'echo cluster_idx = {cluster_idx} | cat - {self.sub_dir}/workspace/temp.m >> temp && mv temp {self.sub_dir}/workspace/temp.m > /dev/null 2>&1 ')


        current_dir = os.getcwd()
        os.chdir(os.path.join(self.sub_dir, 'workspace'))
        os.system(f'matlab -nodesktop -nosplash -r \"temp; exit\"')
        os.system(f'rm {self.sub_dir}/workspace/temp.m')
        os.chdir(current_dir)


    def run(self):
        anat_dir = os.path.join(self.sub_dir, 'anat', 'T1w')
        mni_dir = os.path.join(self.hcp_dir, 'global', 'templates')
        raw_dti_dir = os.path.join(self.sub_dir, 'dti', 'unprocessed')
        if not os.path.exists(f'{self.dti_dir}/ROIs'):
            os.makedirs(f'{self.dti_dir}/ROIs')

        

        os.system(f'cp {self.sub_dir}/func_task/activate_roi/ROIs/* {self.dti_dir}/ROIs/')
        os.system(f'cp {raw_dti_dir}/* {self.dti_dir}/')
        os.system(f'cp {anat_dir}/aparc.a2009s+aseg.nii.gz {self.dti_dir}/aparc.a2009s+aseg.nii.gz')
        os.system(f'cp {anat_dir}/T1w_acpc_dc_restore.nii.gz {self.dti_dir}/T1w_acpc_dc_restore.nii.gz')
        os.system(f'cp {mni_dir}/MNI152_T1_1mm.nii.gz {self.dti_dir}/MNI152_T1_1mm.nii.gz')
        os.system(f'cp {self.dti_script} {self.dti_dir}/01_MRtrix_Preproc_AP_Direction_final.sh')
        
        current_dir = os.getcwd()
        os.chdir(self.dti_dir)
        os.system(f'echo \'MRTRIX3_SHARE={self.mrtrix3}\' > variable.sh')
        os.system(f'echo \'VISTASOFT_HOME={self.vistasoft}\' >> variable.sh')
        os.system(f'bash {self.dti_dir}/01_MRtrix_Preproc_AP_Direction_final.sh 2>&1 | tee -i {self.log_dir}/{self.subj_id}_dti.log')    
        os.system('rm variable.sh')
        os.chdir(current_dir)

class QualityControl:
    def __init__(self):
        self.subj_id = config.DATA_CONFIG['subject_id']
        self.data_dir = config.DATA_CONFIG['root']
        self.sub_dir = os.path.join(self.data_dir, self.subj_id)
        self.task_left = config.TASK_FMRI_CONFIG['task_left']
        self.task_right = config.TASK_FMRI_CONFIG['task_right']

    def add_spec1(self):
        wb_list = [f'{self.sub_dir}/anat/T1w/T1w_acpc_dc_restore.nii.gz', 
                   f'{self.sub_dir}/anat/T1w/T2w_acpc_dc_restore.nii.gz', 
                   f'{self.sub_dir}/anat/T1w/fsaverage_LR32k/{self.subj_id}.L.pial.32k_fs_LR.surf.gii', 
                   f'{self.sub_dir}/anat/T1w/fsaverage_LR32k/{self.subj_id}.R.pial.32k_fs_LR.surf.gii',
                   f'{self.sub_dir}/pfm/Bipartite_PhysicalCommunities+SpatialFiltering.dtseries.nii',
                   f'{self.sub_dir}/pfm/Bipartite_PhysicalCommunities.dtseries.nii',
                   f'{self.sub_dir}/func/rest/session_1/run_1/Rest_{self.task_left}.dtseries.nii', 
                   f'{self.sub_dir}/func/rest/session_1/run_1/Rest_{self.task_right}.dtseries.nii',]
        for item in wb_list:
            os.system(f'wb_command -add-to-spec-file {self.sub_dir}/{self.subj_id}.QC.wb.spec INVALID {item}')

    def add_spec2(self):
        wb_list = [f'{self.sub_dir}/pfm/M1_TargetNetwork.dtseries.nii',
                   f'{self.sub_dir}/pfm/S1_TargetNetwork.dtseries.nii']
        for item in wb_list:
            os.system(f'wb_command -add-to-spec-file {self.sub_dir}/{self.subj_id}.QC.wb.spec INVALID {item}')


# def main():
#     rs = rsfMRIProcessor(multi_echo=True)
#     task = taskfMRIProcessor()
#     dti = DTIProcessor()
#     qc = QualityControl()

#     # 1. 原始文件转格式
#     rs.format_transform()
#     # 2. 结构向预处理
#     rs.anat_pipline()
#     # 3. 静息态预处理
#     rs.multi_echo_pipline()
#     # 4. pfm聚类
#     rs.pfm()
#     # 5. 任务态处理    
#     task.run()
#     # 6. dti处理
#     dti.run()
#     #----------------------------
#     # 选cluster (wb_view)
#     dti.get_target(hemi='rh')
#     # 7. QC
#     qc.add_spec()
#     # ---------------------------
#     # Tans_generate_ROI.mlx
#     # 8. tans
#     rs.tans()

# if __name__ == "__main__":
#     main()