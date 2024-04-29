from StrokeTMSPipline import DTIProcessor, QualityControl
from config import DATA_CONFIG

dense_idx = 6


if __name__ == '__main__':
    dti = DTIProcessor()
    qc = QualityControl()
    hemi = DATA_CONFIG['hemi']
    #----------------------------
    # 选cluster (wb_view)
    dti.get_target(cluster_idx=dense_idx, hemi=hemi) # ~2 hours
    # 7. QC
    qc.add_spec2()