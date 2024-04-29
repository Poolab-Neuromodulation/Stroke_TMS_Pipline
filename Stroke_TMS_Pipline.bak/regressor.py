import numpy as np
import pandas as pd
import os
import codecs, json
from scipy.io import savemat, loadmat

def read_json(path):
    data_text = codecs.open(path, 'r', encoding='utf-8').read()
    data = json.loads(data_text)
    return data

def motion_regressor(nuisance_path, output_path):
    motion = pd.read_csv(nuisance_path, sep='\t',
                            usecols=['trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z',
                                    'trans_x_derivative1', 'trans_y_derivative1', 'trans_z_derivative1',
                                    'rot_x_derivative1', 'rot_y_derivative1', 'rot_z_derivative1'])
    motion = np.asarray(motion.replace(np.nan, 0))
    savemat(output_path, {'score': motion})


def csf_wm_regressor(nuisance_path, json_paths, output_path, ratio=50):
    nuisance_path = nuisance_path
    nuisance_json = read_json(json_paths)
    usecols = []
    for j in range(200):
        j = '0'  + str(j) if j < 10 else str(j)
        usecols.append('c_comp_cor_' + j)
        if nuisance_json['c_comp_cor_' + j]['CumulativeVarianceExplained'] * 100 > ratio:
            break
    for j in range(200):
        j = '0'  + str(j) if j < 10 else str(j)
        usecols.append('w_comp_cor_' + j)
        if nuisance_json['w_comp_cor_' + j]['CumulativeVarianceExplained'] * 100 > ratio :
            break
    
    motion = pd.read_csv(nuisance_path, sep='\t',
                            usecols=usecols)
                        #  usecols=['csf', 'white_matter'])
                        #  usecols=['csf_wm'])
    motion = np.asarray(motion.replace(np.nan, 0))
    savemat(output_path, {'score': motion})

# def physiology_regressor(self, data_path, mask_path, output_path, n_pca=0, intensity_threshold=0.005, explained_ratio=50):
#     n_pca = self.eng.pca_volume(data_path, mask_path, output_path, n_pca, intensity_threshold, explained_ratio, nargout=1) # explane 50%
#     return n_pca


def physiology_regressor_split(output_path, n_pcas):
    for pca_i in range(0, len(n_pcas)):  # 0, 1
        pca = loadmat(output_path)['score'][:, 0:n_pcas[pca_i]]
        path, fname = os.path.split(output_path)
        savemat(os.path.join(path, fname.replace(str(n_pcas[-1]), str(n_pcas[pca_i]))), {'score': pca})
        
def combine_all_regressor(data_paths, output_path):
    motion_physiology = []
    for i in range(len(data_paths)):
        motion_physiology.append(loadmat(data_paths[i])['score'])
    motion_physiology = np.concatenate(motion_physiology, axis=1)
    savemat(output_path, {'score':motion_physiology})
