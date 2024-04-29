from StrokeTMSPipline import rsfMRIProcessor
from run_2 import dense_idx
from config import DATA_CONFIG


M1_cluster_idx = 27
S1_cluster_idx = 27


if __name__ == '__main__':
    rs = rsfMRIProcessor(n_thread=64)
    hemi = DATA_CONFIG['hemi']
    # ---------------------------
    # 8. tans
    # ~11 hours
    rs.tans(dense_idx=dense_idx, M1_cluster_idx=M1_cluster_idx, S1_cluster_idx=S1_cluster_idx, hemi=hemi)