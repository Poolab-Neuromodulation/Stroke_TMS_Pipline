# 1. 原始数据地址 DATA_CONFIG['source']
# 2. 被试编号 DATA_CONFIG['subject_id']
# 3. 任务态psychopy启动延迟 TASK_FMRI_CONFIG['delay']

LOG_DIR = '/home/cputest/Stroke/Code/log'

SCRIPTS_CONFIG = {
    'MultiEcho' : '/home/cputest/Stroke/github_TMS_pipline/Stroke_TMS_Pipline/MultiEchofMRI-Pipeline',
    'HCPPipline': '/home/cputest/Stroke/github_TMS_pipline/Stroke_TMS_Pipline/HCPpipelines',
    'PFM' : '/home/cputest/Stroke/github_TMS_pipline/Stroke_TMS_Pipline/PFM',
    'TANS' : '/home/cputest/Stroke/github_TMS_pipline/Stroke_TMS_Pipline/TANS',
} 

DATA_CONFIG = {
    'source' : '/home/cputest/Stroke/Data/sub004_raw', # 1
    'root' : '/home/cputest/Stroke/Data/',
    'subject_id': 'ME13', # 2
    'hemi': 'rh', # 3
}

SIMNIBS_CONFIG = {
    'LD_LIBRARY' : '/home/cputest/SimNIBS-4.1/simnibs_env/lib/python3.9/site-packages/simnibs/external/lib/linux',
    'root' : '/home/cputest/SimNIBS-4.1',
}

DTI_CONFIG = {
    # 'root': '/home/cputest/Stroke/Code/DTI/Code/mrtrix_data/P_hejieshi',
    'script': '/home/cputest/Stroke/github_TMS_pipline/Stroke_TMS_Pipline/DTI/',
    'VISTASOFT' : '/home/cputest/Stroke/github_TMS_pipline/Stroke_TMS_Pipline/DTI/vistasoft-master',
    'MRTRIX3_SHARE': '/home/cputest/anaconda3/share/mrtrix3'
}

TASK_FMRI_CONFIG = {
    'script': '/home/cputest/Stroke/github_TMS_pipline/Stroke_TMS_Pipline/Stroke_TMS_Pipline/task_fmri_script',
    'task_left': 'left_finger_motor',
    'task_right': 'right_finger_motor',
    'delay': 2.51, # 4
}
