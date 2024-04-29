input_dir=$1
TargetSpace=$2
output_file=$3
# input_dir=/home/poolab/HDD_4T/Stroke_data/TMS_Stroke/YangZhi/sub001/func/rest/session_1/run_1
# TargetSpace=/home/poolab/HDD_4T/Stroke_data/TMS_Stroke/YangZhi/sub001/func/xfms/rest/T1w_acpc_brain_func_mask.nii.gz
# output_file=/home/poolab/HDD_4T/Stroke_data/TMS_Stroke/YangZhi/sub001/func/rest/session_1/run_1/sub001_bold.nii.gz

cd $input_dir
fslinfo $input_dir/clean_data.nii | grep ^dim4 > info.txt
max_t=$(awk '{print $2}' info.txt)
rm info.txt
fslsplit $input_dir/clean_data.nii -t

files=()

for ((i=0;i<$max_t;i++));  do 
    file_number=$(printf "%04d" $i)
    #echo $file_number
    file_name="vol${file_number}.nii.gz"
    InputFile="${input_dir}/${file_name}"
    OutputFile="${input_dir}/resamp_${file_name}"
    files+=("${OutputFile}")
    echo "y_Reslice('$InputFile', '$OutputFile', [3 3 3], 0, '$TargetSpace');" >> temp.m
done
matlab -nodesktop -nosplash -r "temp; exit"
fslmerge -t "${output_file}" "${files[@]}"

rm temp.m
rm ${input_dir}/resamp*
rm ${input_dir}/vol*
