Subject=$1
StudyFolder=$2
Subdir="$StudyFolder"/"$Subject"
MEDIR=$3
s=1
r=1
AtlasTemplate="$MEDIR/res0urces/FSL/MNI152_T1_2mm.nii.gz"

rm -rf "$Subdir"/workspace/ > /dev/null 2>&1
mkdir "$Subdir"/workspace/ > /dev/null 2>&1

cp -rf "$MEDIR"/res0urces/make_precise_subcortical_labels.m \
"$Subdir"/workspace/temp.m

# define some Matlab variables;
echo "addpath(genpath('${MEDIR}'))" | cat - "$Subdir"/workspace/temp.m > temp && mv temp "$Subdir"/workspace/temp.m
echo Subdir=["'$Subdir'"] | cat - "$Subdir"/workspace/temp.m >> temp && mv temp "$Subdir"/workspace/temp.m > /dev/null 2>&1 		
echo AtlasTemplate=["'$AtlasTemplate'"] | cat - "$Subdir"/workspace/temp.m >> temp && mv temp "$Subdir"/workspace/temp.m > /dev/null 2>&1 		
echo SubcorticalLabels=["'$MEDIR/res0urces/FS/SubcorticalLabels.txt'"] | cat - "$Subdir"/workspace/temp.m >> temp && mv temp "$Subdir"/workspace/temp.m > /dev/null 2>&1 		
cd "$Subdir"/workspace/ # run script via Matlab 
matlab -nodesktop -nosplash -r "temp; exit" > /dev/null 2>&1
rm "$Subdir"/workspace/temp.m


cp -rf "$MEDIR"/res0urces/mgtr_volume.m \
	"$Subdir"/workspace/temp.m

		# define some Matlab variables
echo Input=["'$Subdir/func/rest/session_$s/run_$r/Rest_OCME+MEICA.nii.gz'"] | cat - "$Subdir"/workspace/temp.m > temp && mv temp "$Subdir"/workspace/temp.m
echo Subdir=["'$Subdir'"]  | cat - "$Subdir"/workspace/temp.m >> temp && mv temp "$Subdir"/workspace/temp.m
echo Output_MGTR=["'$Subdir/func/rest/session_$s/run_$r/Rest_OCME+MEICA+MGTR'"] | cat - "$Subdir"/workspace/temp.m >> temp && mv temp "$Subdir"/workspace/temp.m
echo Output_Betas=["'$Subdir/func/rest/session_$s/run_$r/Rest_OCME+MEICA+MGTR_Betas'"] | cat - "$Subdir"/workspace/temp.m >> temp && mv temp "$Subdir"/workspace/temp.m
echo "addpath(genpath('${MEDIR}'))" | cat - "$Subdir"/workspace/temp.m >> temp && mv temp "$Subdir"/workspace/temp.m

cd "$Subdir"/workspace/ # perform mgtr using Matlab
matlab -nodesktop -nosplash -r "temp; exit"
rm "$Subdir"/workspace/temp.m
