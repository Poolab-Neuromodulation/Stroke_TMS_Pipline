from StrokeTMSPipline import DTIProcessor, QualityControl

dense_idx = 1
hemi = 'rh'



dti = DTIProcessor()
qc = QualityControl()
#----------------------------
# 选cluster (wb_view)
dti.get_target(dense_idx, hemi='rh') # ~2 hours
# 7. QC
qc.add_spec()