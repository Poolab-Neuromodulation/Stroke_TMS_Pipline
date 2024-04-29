

% setenv('LD_LIBRARY_PATH', sprintf('/home/cputest/anaconda3/lib:%s', getenv('LD_LIBRARY_PATH')));

str = strsplit(Subdir,'/'); Subject = str{end};
MidthickSurfs{1} = [Subdir '/anat/T1w/fsaverage_LR32k/' Subject '.L.midthickness.32k_fs_LR.surf.gii'];
MidthickSurfs{2} = [Subdir '/anat/T1w/fsaverage_LR32k/' Subject '.R.midthickness.32k_fs_LR.surf.gii'];
meanFD = grayplot_qa_func(Subdir);
%meanFD = grayplot_qa_func_se(Subdir);

if meanFD > 0.5
    threshold = meanFD;
else
    threshold = 0.5;
end
threshold = 0.5;
% concatenate and smooth resting-state fMRI datasets;
nSessions = length(dir([Subdir '/func/rest/session_*']));
[C,ScanIdx,FD] = concatenate_scans(Subdir,'Rest_OCME+MEICA+MGTR',1:nSessions);
mkdir([Subdir '/func/rest/ConcatenatedCiftis']);
cd([Subdir '/func/rest/ConcatenatedCiftis']);

% make distance matrix and then regress
% adjacent cortical signals from subcortical voxels;
make_distance_matrix(C,MidthickSurfs,[Subdir '/anat/T1w/fsaverage_LR32k/'],nThreads);  

[C] = regress_cortical_signals(C,[Subdir '/anat/T1w/fsaverage_LR32k/DistanceMatrix.mat'],20);
% hejieshi: regress llless subcortical signal
% [C] = regress_cortical_signals(C,[Subdir '/anat/T1w/fsaverage_LR32k/DistanceMatrix.mat'],10);
ft_write_cifti_mod([Subdir '/func/rest/ConcatenatedCiftis/Rest_OCME+MEICA+MGTR_Concatenated+SubcortRegression.dtseries.nii'],C);
save([Subdir '/func/rest/ConcatenatedCiftis/ScanIdx'],'ScanIdx');
save([Subdir '/func/rest/ConcatenatedCiftis/FD'],'FD');
clear C % clear intermediate file

% sweep a range of
% smoothing kernels;
for k = [0.85 1.7 2.55]
    smooth_cifti(Subdir,'Rest_OCME+MEICA+MGTR_Concatenated+SubcortRegression.dtseries.nii',['Rest_OCME+MEICA+MGTR_Concatenated+SubcortRegression+SpatialSmoothing' num2str(k) '.dtseries.nii'],k,k);
end

load([Subdir '/func/rest/ConcatenatedCiftis/FD']);
C = ft_read_cifti_mod([Subdir '/func/rest/ConcatenatedCiftis/Rest_OCME+MEICA+MGTR_Concatenated+SubcortRegression+SpatialSmoothing2.55.dtseries.nii']);
% C.data(:,FD>1.5)=[]; % remove high motion volumes
C.data(:,FD>threshold)=[]; % remove high motion volumes
C.data = single(C.data);


% pfm
%pfm(C,[Subdir '/anat/T1w/fsaverage_LR32k/DistanceMatrix.mat'],[Subdir '/pfm/'],[0.0005],[50],20,[],{'CORTEX_LEFT','CEREBELLUM_LEFT','ACCUMBENS_LEFT','CAUDATE_LEFT','PALLIDUM_LEFT','PUTAMEN_LEFT','THALAMUS_LEFT','HIPPOCAMPUS_LEFT','AMYGDALA_LEFT','ACCUMBENS_LEFT','CORTEX_RIGHT','CEREBELLUM_RIGHT','ACCUMBENS_RIGHT','CAUDATE_RIGHT','PALLIDUM_RIGHT','PUTAMEN_RIGHT','THALAMUS_RIGHT','HIPPOCAMPUS_RIGHT','AMYGDALA_RIGHT','ACCUMBENS_RIGHT'},1);
% spatial_filtering([Subdir '/pfm/Bipartite_PhysicalCommunities.dtseries.nii'],[Subdir '/pfm/'],['Bipartite_PhysicalCommunities+SpatialFiltering.dtseries.nii'],MidthickSurfs,50,100);

pfm(C,[Subdir '/anat/T1w/fsaverage_LR32k/DistanceMatrix.mat'],[Subdir '/pfm/'],[0.0002 0.0005 0.001 0.002],[100 100 50 50],10,[],{'CORTEX_LEFT','CEREBELLUM_LEFT','ACCUMBENS_LEFT','CAUDATE_LEFT','PALLIDUM_LEFT','PUTAMEN_LEFT','THALAMUS_LEFT','HIPPOCAMPUS_LEFT','AMYGDALA_LEFT','ACCUMBENS_LEFT','CORTEX_RIGHT','CEREBELLUM_RIGHT','ACCUMBENS_RIGHT','CAUDATE_RIGHT','PALLIDUM_RIGHT','PUTAMEN_RIGHT','THALAMUS_RIGHT','HIPPOCAMPUS_RIGHT','AMYGDALA_RIGHT','ACCUMBENS_RIGHT'},nThreads);

spatial_filtering([Subdir '/pfm/Bipartite_PhysicalCommunities.dtseries.nii'],[Subdir '/pfm/'],['Bipartite_PhysicalCommunities+SpatialFiltering.dtseries.nii'],MidthickSurfs,100,100);

