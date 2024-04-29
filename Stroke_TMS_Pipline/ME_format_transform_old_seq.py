import os, re
import shutil
import json
import config

class FormatTransformer:
    def __init__(self, dcm_dir, nii_dir, subj_id):
        self.dcm_dir = dcm_dir
        self.nii_dir = nii_dir
        self.subj_id = subj_id
        self.tmp_dir = os.path.join(self.nii_dir,  f'{self.subj_id}/tmp')
        if not os.path.exists(self.tmp_dir):
            os.makedirs(self.tmp_dir)
    
    def __del__(self):
        shutil.rmtree(self.tmp_dir, ignore_errors=True)

    def write_fieldmap_json(self, file, new_dict):
        with open(file, "r") as f:
            load_dict = json.load(f)
        load_dict["PhaseEncodingDirection"] = new_dict
        with open(file, "w") as f:
            json.dump(load_dict, f)

    def dicom2nifti(self, input_dir, output_dir, name):
        
        os.system(f'dcm2niix -o {self.tmp_dir} -z y {input_dir}')
        
        nii_list = os.listdir(self.tmp_dir)
        for f in nii_list:
            try:
                if f.endswith('.json'):
                    output_path = os.path.join(output_dir, name+'.json')
                elif f.endswith('.nii.gz'):
                    output_path = os.path.join(output_dir, name+'.nii.gz')
                elif f.endswith('.bvec'):
                    output_path = os.path.join(output_dir, name+'.bvec')
                elif f.endswith('.bval'):
                    output_path = os.path.join(output_dir, name+'.bval')
                # output_path = os.path.join(output_dir, name+'.'+f.split('.')[-1])
                shutil.move(os.path.join(self.tmp_dir, f), output_path)
            except:
                print('ERROR!')
        
    def fmriprep_anat_convert(self, t1_pattern=r't1', t2_pattern=r't2'):
        for mod in ['T1w', 'T2w']:
            pattern = t1_pattern if (mod=='T1w') else t2_pattern
            anat_dir = os.path.join(self.nii_dir, f'sub-{self.subj_id}/anat')
            if not os.path.exists(anat_dir):
                os.makedirs(anat_dir)
            for s in os.listdir(self.dcm_dir):
                if re.findall(pattern, s) != []:
                    self.dicom2nifti(os.path.join(self.dcm_dir, s), anat_dir, f'sub-{self.subj_id}_'+mod)

    # def fmriprep_func_convert(self, bold_pattern=r't1'):
    #     pass

    def me_anat_convert(self, t1_pattern=r't1', t2_pattern=r't2'): 
        for mod in ['T1w', 'T2w']:
            pattern = t1_pattern if (mod=='T1w') else t2_pattern
            anat_dir = os.path.join(self.nii_dir, f'{self.subj_id}/anat/unprocessed/{mod}')
            if not os.path.exists(anat_dir):
                os.makedirs(anat_dir)
            for s in os.listdir(self.dcm_dir):
                if re.findall(pattern, s) != []:
                    self.dicom2nifti(os.path.join(self.dcm_dir, s), anat_dir, mod)

    def me_func_convert(self, fm_pattern=r'fieldmap', me_pattern=r'me', echo_pattern=r'Echo\d', echo1_pattern=r'Echo1', echo2_pattern='Echo2', b0map_pattern='B0Map'):
        func_dir = os.path.join(self.nii_dir, f'{self.subj_id}/func/unprocessed/rest/session_1/run_1')
        fm_dir = os.path.join(self.nii_dir, f'{self.subj_id}/func/unprocessed/field_maps')
        if not os.path.exists(func_dir):
            os.makedirs(func_dir)
        if not os.path.exists(fm_dir):
            os.makedirs(fm_dir)
        for s in os.listdir(self.dcm_dir):
            if re.findall(me_pattern, s) != []:
                me_n = re.findall(echo_pattern, s)[0][-1]
                fm_n = int(re.findall(r'(\d+)0\d', s)[0]) + 1
                self.dicom2nifti(os.path.join(self.dcm_dir, s), func_dir, 'Rest_S1_R1_E'+me_n)
        for s in os.listdir(self.dcm_dir):
            if re.findall(fm_pattern, s) != [] and re.findall(echo1_pattern, s) != [] and re.findall(rf'{fm_n}0\d+', s) != []:
                self.dicom2nifti(os.path.join(self.dcm_dir, s), fm_dir, 'magnitude1_S1_R1')
            if re.findall(fm_pattern, s) != [] and re.findall(echo2_pattern, s) != [] and re.findall(rf'{fm_n}0\d+', s) != []:
                self.dicom2nifti(os.path.join(self.dcm_dir, s), fm_dir, 'magnitude2_S1_R1')
            if re.findall(fm_pattern, s) != [] and re.findall(b0map_pattern, s) != [] and re.findall(rf'{fm_n}0\d+', s) != []:
                self.dicom2nifti(os.path.join(self.dcm_dir, s), fm_dir, 'phasediff_S1_R1')

    def fmriprep_format(self, t1_pattern=r't1', t2_pattern=r't2', fm_pattern=r'fieldmap', me_pattern=r'me', echo_pattern=r'Echo\d', echo1_pattern=r'Echo1', echo2_pattern='Echo2'):
        self.fmriprep_anat_convert(t1_pattern, t2_pattern)
    #     self.fmriprep_func_convert()

    def me_dti_convert(self, dti_pattern=r'dti', ap_pattern=r'AP', pa_pattern=r'PA'): 
        dti_dir = os.path.join(self.nii_dir, f'{self.subj_id}/dti/unprocessed')
        if not os.path.exists(dti_dir):
            os.makedirs(dti_dir)
        for s in os.listdir(self.dcm_dir):
            if re.findall(dti_pattern, s) != [] and re.findall(ap_pattern, s) != []:
                self.dicom2nifti(os.path.join(self.dcm_dir, s), dti_dir, 'DTI_b0_AP')
            if re.findall(dti_pattern, s) != [] and re.findall(pa_pattern, s) != []:
                self.dicom2nifti(os.path.join(self.dcm_dir, s), dti_dir, 'DTI')

    def func_task_convert(self):
        task_dir = os.path.join(self.nii_dir, f'{self.subj_id}/func_task/unprocessed')
        task_working_dir = os.path.join(self.nii_dir, f'{self.subj_id}/func_task/afni_result')
        task_ouput_dir = os.path.join(self.nii_dir, f'{self.subj_id}/func_task/activate_roi')
        if not os.path.exists(task_dir):
            os.makedirs(task_dir)
        if not os.path.exists(task_working_dir):
            os.makedirs(task_working_dir)
        if not os.path.exists(task_ouput_dir):
            os.makedirs(task_ouput_dir)

        raw_task_dir = config.TASK_FMRI_CONFIG['source']
        self.dicom2nifti(raw_task_dir, task_dir, 'bold_task_hand_motor')
        # for s in os.listdir(self.dcm_dir):
        #     if re.findall(dti_pattern, s) != [] and re.findall(ap_pattern, s) != []:
        #         self.dicom2nifti(os.path.join(self.dcm_dir, s), dti_dir, 'DTI_b0_AP')


    def multi_echo_format(self, t1_pattern=r't1', t2_pattern=r't2', fm_pattern=r'fieldmap', me_pattern=r'me', echo_pattern=r'Echo\d', echo1_pattern=r'Echo1', echo2_pattern=r'Echo2', b0map_pattern=r'B0Map', dti_pattern=r'dti', ap_pattern=r'AP', pa_pattern=r'PA'):
        self.me_anat_convert(t1_pattern=t1_pattern, t2_pattern=t2_pattern)
        self.me_func_convert(fm_pattern=fm_pattern, me_pattern=me_pattern, echo_pattern=echo_pattern, echo1_pattern=echo1_pattern, echo2_pattern=echo2_pattern, b0map_pattern=b0map_pattern)
        self.me_dti_convert(dti_pattern=dti_pattern, ap_pattern=ap_pattern, pa_pattern=pa_pattern)
        self.func_task_convert()

if __name__ == "__main__":
    source_dir = rf'/mnt/nas/lglab/Projects/TMS_stroke/human/strokepatients/MRI/sub019_xjy_20240204'
    nii_dir = rf'/home/guoxl/fmridata/wyStroke/Liston-Laboratory-MultiEchofMRI-Pipeline-master/ExampleData_run2'
    # mods = ['T1w', 'T2w', 'field_maps', 'Multi_Echos']

    ft = FormatTransformer(source_dir, nii_dir, subj_id='ME19')
    ft.multi_echo_format()
    # ft.fmriprep_anat_convert()
