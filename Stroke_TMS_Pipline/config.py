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
    'script': '/home/cputest/Stroke/Code/DTI/',
    'VISTASOFT' : '/home/cputest/Stroke/Code/DTI/vistasoft-master',
    'MRTRIX3_SHARE': '/home/cputest/anaconda3/share/mrtrix3'
}

TASK_FMRI_CONFIG = {
    # 'source': '/home/poolab/NAS/Projects/TMS_stroke/human/1_RuiJinHospital/strokepatients/MRI/sub003_sbm_20240412/bold_2.4mmiso_se_task_SaveBySlc_302',
    'script': '/home/cputest/Stroke/Code/Stroke_TMS_Pipline/task_fmri_script',
    'task_left': 'left_finger_motor',
    'task_right': 'right_finger_motor',
    'delay': 3.26, # 4
}