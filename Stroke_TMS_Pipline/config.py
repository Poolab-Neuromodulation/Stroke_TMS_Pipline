# 1. 原始数据地址 DATA_CONFIG['source']
# 2. 被试编号 DATA_CONFIG['subject_id']
# 3. 任务态psychopy启动延迟 TASK_FMRI_CONFIG['delay']

LOG_DIR = '/home/cputest/Stroke/Code/log'

SCRIPTS_CONFIG = {
    'MultiEcho' : '/home/cputest/Stroke/Code/MultiEchofMRI-Pipeline',
    'HCPPipline': '/home/cputest/Stroke/Code/HCPpipelines',
    'PFM' : '/home/cputest/Stroke/Code/Targeted-Functional-Network-Stimulation-main/PFM',
    'TANS' : '/home/cputest/Stroke/Code/Targeted-Functional-Network-Stimulation-main/TANS',
} 

DATA_CONFIG = {
    'source': '/home/cputest/disk_480G/github_test/sub003_sbm_20240412', # 1
    'root' : '/home/cputest/disk_480G/github_test',
    'subject_id': 'sub003', # 2
    'hemi': 'rh', # 3
}

SIMNIBS_CONFIG = {
    'LD_LIBRARY' : '/home/cputest/SimNIBS-4.1/simnibs_env/lib/python3.9/site-packages/simnibs/external/lib/linux',
    'root' : '/home/cputest/SimNIBS-4.1',
}

DTI_CONFIG = {
    # 'root': '/home/cputest/Stroke/Code/DTI/Code/mrtrix_data/P_hejieshi',
    'script': '/home/cputest/Stroke/Code/DTI/',
    'VISTASOFT' : '/home/cputest/Stroke/Code/DTI/vistasoft-master',
    'MRTRIX3_SHARE': '/home/cputest/anaconda3/share/mrtrix3'
}

TASK_FMRI_CONFIG = {
    'script': '/home/cputest/Stroke/Code/Stroke_TMS_Pipline/task_fmri_script',
    'task_left': 'left_finger_motor',
    'task_right': 'right_finger_motor',
    'delay': 2.51, # 4
}