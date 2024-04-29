from StrokeTMSPipline import rsfMRIProcessor, taskfMRIProcessor, DTIProcessor


rs = rsfMRIProcessor(multi_echo=True)
task = taskfMRIProcessor()
dti = DTIProcessor()

# 1. 原始文件转格式
rs.format_transform()
# 2. 结构向预处理
rs.anat_pipline() # ~8 hours
# 3. 静息态预处理
rs.multi_echo_pipline() # ~4 hours
# 4. pfm聚类
rs.pfm() # ~2.5 hours
# 5. 任务态处理    
task.run() # ~0.5 hours
# 6. dti处理
dti.run() # ~3 hours