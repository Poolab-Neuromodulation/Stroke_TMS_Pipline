# 1. 原始数据地址 DATA_CONFIG['source']
# 2. 被试编号 DATA_CONFIG['subject_id']
# 3. 任务态psychopy启动延迟 TASK_FMRI_CONFIG['delay']

LOG_DIR = '/home/poolab/HDD_4T/Stroke_data/Patient_data/multi_echo/log'

SCRIPTS_CONFIG = {
    'MultiEcho' : '/home/poolab/HeJieShi/MultiEchofMRI-Pipeline',
    'HCPPipline': '/home/poolab/HeJieShi/HCPpipelines',
    'PFM' : '/home/poolab/HeJieShi/Targeted-Functional-Network-Stimulation-main/PFM',
    'TANS' : '/home/poolab/HeJieShi/Targeted-Functional-Network-Stimulation-main/TANS',
} 

DATA_CONFIG = {
    'source' : '/home/poolab/NAS/Projects/TMS_stroke/human/strokepatients/MRI/sub018_ljg_20240119',
    'root' : '/home/poolab/HDD_4T/Stroke_data/Health_data/multi_echo/Pipline_test',
    'subject_id' : 'ME18',
}

SIMNIBS_CONFIG = {
    'LD_LIBRARY' : '/home/poolab/SimNIBS-4.0/simnibs_env/lib/python3.9/site-packages/simnibs/external/lib/linux',
    'root' : '/home/poolab/SimNIBS-4.0',
}

DTI_CONFIG = {
    # 'root': '/home/poolab/HeJieShi/DTI/Code/mrtrix_data/P_hejieshi',
    'script': '/home/poolab/HeJieShi/DTI/Code/',
    'VISTASOFT' : '/home/poolab/HeJieShi/DTI/Code/vistasoft-master',
    'MRTRIX3_SHARE': '/home/poolab/anaconda3/share/mrtrix3'
}

TASK_FMRI_CONFIG = {
    'source': '/home/poolab/NAS/Projects/TMS_stroke/human/strokepatients/MRI/sub018_ljg_20240119/epi_bold_mb6_iso2.4mm_950_SaveBy_301',
    'script': '/home/poolab/HeJieShi/Stroke_TMS_Pipline/task_fmri_script',
    'task_left': 'left_finger_motor',
    'task_right': 'right_finger_motor',
    'delay': 2.8
}