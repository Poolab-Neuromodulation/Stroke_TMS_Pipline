import os
import sys
import config



def main():
    # print(config.SUB_ID)
    # sub_id = config.DATA_CONFIG['subject_id']
    afni_script_root = config.TASK_FMRI_CONFIG['script']


    sub_id = "ME13"
    # cp t1w_restore_brain
    anat = rf'/home/poolab/HDD_4T/Stroke_data/Health_data/multi_echo/ME13/anat/T1w/T1w_acpc_dc_restore_brain.nii.gz'
    os.system(rf'cp {anat} /home/poolab/HDD_4T/Stroke_data/Health_data/multi_echo/ME13/func_task/unprocessed')
    anat = '/home/poolab/HDD_4T/Stroke_data/Health_data/multi_echo/ME13/func_task/unprocessed/T1w_acpc_dc_restore_brain.nii.gz'
    dsets = rf'/home/poolab/HDD_4T/Stroke_data/Health_data/multi_echo/ME13/func_task/unprocessed/bold_task_hand_motor.nii.gz'
    stim_times_left = rf'/home/poolab/HDD_4T/Stroke_data/Health_data/multi_echo/ME13/func_task/unprocessed/Motor_left.txt'
    stim_times_right = rf'/home/poolab/HDD_4T/Stroke_data/Health_data/multi_echo/ME13/func_task/unprocessed/Motor_right.txt'

    task_fmri_work_dir = "read from config"
    task_fmri_work_dir = "/home/poolab/HDD_4T/Stroke_data/Health_data/multi_echo/ME13/func_task/afni_result"
    os.chdir(task_fmri_work_dir)
    os.system('cp {afni_script_root}/cmd.ap ./')
    os.system(rf'tcsh ./cmd.ap {sub_id} {anat} {dsets} {stim_times_left} {stim_times_right}')
    
    slice_timing = rf'/home/poolab/HDD_4T/Stroke_data/Health_data/multi_echo/ME13/func_task/unprocessed/SliceTiming.1D'
    new_lines = []
    with open(rf'proc.{sub_id}', 'r') as f:
        for line in f.readlines():
            if line.strip() == '# QC: look for columns of high variance':
                new_lines.append(open(slice_timing, 'r').read())
                # new_lines.append('exit\n')
            new_lines.append(line)
    with open(rf'proc.{sub_id}', 'w') as f:
        f.writelines(new_lines)
    log_dir = config.LOG_DIR
    log_dir = './'
    os.system(rf'tcsh -xef proc.{sub_id} 2>&1 | tee {log_dir}/output.proc.{sub_id}')

    # afni postprocess
    # all read from config"
    sub_id = "ME13"
    log_dir = './'
    afni_result_dir = rf'/home/poolab/HDD_4T/Stroke_data/Health_data/multi_echo/ME13/func_task/afni_result/ME13.results'
    output_dir = rf'/home/poolab/HDD_4T/Stroke_data/Health_data/multi_echo/ME13/func_task/activate_roi'
    
    study_folder = rf'/home/poolab/HDD_4T/Stroke_data/Health_data/multi_echo'
    os.system(rf'bash {afni_script_root}/afni_postprocess.sh {sub_id} {afni_result_dir} {output_dir} {afni_script_root} {study_folder} 2>&1 | tee {log_dir}/afni_postprocess.sh.{sub_id}.log')



if __name__ =="__main__":
    main()