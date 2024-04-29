import nibabel as nib
import numpy as np

import sys

def main():
    arg1 = sys.argv[1]
    print("processing ", arg1)

    # 读取4D数据
    input_file = arg1
    img = nib.load(input_file)
    data = np.squeeze(img.get_fdata())

    # 拆分为多个3D数据
    for t in range(data.shape[-1]):
        # 创建一个3D数据
        output_data = data[:, :, :, t]
        # 保存为独立的文件
        output_file = f'output_{t+1}.nii.gz'
        output_img = nib.Nifti1Image(output_data, img.affine)
        nib.save(output_img, output_file)


if __name__ == '__main__':
    main()




