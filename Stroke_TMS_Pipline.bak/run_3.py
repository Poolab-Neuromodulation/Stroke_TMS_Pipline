from StrokeTMSPipline import rsfMRIProcessor

dense_idx = 1
M1_cluster_idx = 17
S1_cluster_idx = 5
hemi = 'rh'



rs = rsfMRIProcessor()

# ---------------------------
# 8. tans
# ~11 hours
rs.tans(dense_idx=dense_idx, M1_cluster_idx=M1_cluster_idx, S1_cluster_idx=S1_cluster_idx, hemi='rh')