setenv('LD_LIBRARY_PATH', sprintf([SimNIBS_LD_PATH ':%s'], getenv('LD_LIBRARY_PATH')))
for i = 1:length(Paths)
    addpath(genpath(Paths{i}));
end


T1w = [DataDir '/' Subject '/anat/T1w/T1w_acpc_dc_restore.nii.gz'];
T2w = [DataDir '/' Subject '/anat/T1w/T2w_acpc_dc_restore.nii.gz'];
OutDir = [DataDir '/' Subject '/tans'];
    
% run the tans_headmodels function;
tans_headmodels(Subject,T1w,T2w,OutDir,Paths);
