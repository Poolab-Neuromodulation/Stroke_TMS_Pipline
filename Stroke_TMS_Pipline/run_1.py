from StrokeTMSPipline import rsfMRIProcessor, taskfMRIProcessor, DTIProcessor, QualityControl
from threading import Thread
import time


rs = rsfMRIProcessor(multi_echo=True, n_thread=64)
task = taskfMRIProcessor()
dti = DTIProcessor()
qc = QualityControl()

def format_transform1(me_pattern=r'5cho_Echo'):
    rs.format_transform(me_pattern=me_pattern)

def anat_pipline1():
    rs.anat_pipline()

def multi_echo_pipline1():
    rs.multi_echo_pipline()

def single_echo_pipline1():
    rs.single_echo_pipline()

def pfm1():
    rs.pfm()

def task1():
    task.run()

def dti1():
    dti.run()

def tans_head_model1():
    rs.tans_head_model()

def qc1():
    qc.add_spec1()


if __name__ == '__main__':
    


    t_start = time.time()

    """
    # 15.3 hours
    # 1. 原始文件转格式
    rs.format_transform(me_pattern=r'5cho_Echo')
    # 2. 结构向预处理
    rs.anat_pipline() # ~8 hours
    # 3. 静息态预处理
    rs.multi_echo_pipline() # ~4 hours
    # rs.single_echo_pipline()
    # 4. pfm聚类
    rs.pfm() # ~2.5 hours
    # 5. 任务态处理    
    task.run() # ~0.5 hours
    # 6. dti处理
    dti.run() # ~3 hours
    qc.add_spec1()
    """

    t1 = Thread(target=format_transform1)
    t2 = Thread(target=anat_pipline1)
    t3 = Thread(target=multi_echo_pipline1)
    t4 = Thread(target=pfm1)
    t5 = Thread(target=task1)
    t6 = Thread(target=dti1)
    t7 = Thread(target=qc1)
    t8 = Thread(target=tans_head_model1)

    t1.start()
    t1.join()
    t2.start()
    t2.join()
    t3.start()
    t5.start()
    t5.join()
    t6.start()
    t3.join()
    t6.join()
    t4.start()
    t4.join()
    t7.start()
    t7.join()
    t8.start()
    t8.join()


    print("======================")
    print(f"total time: {(time.time() - t_start) / 60} minutes")