setenv('LD_LIBRARY_PATH', sprintf([SimNIBS_LD_PATH ':%s'], getenv('LD_LIBRARY_PATH')))
for i = 1:length(Paths)
    addpath(genpath(Paths{i}));
end


T1w = [DataDir '/' Subject '/anat/T1w/T1w_acpc_dc_restore.nii.gz'];
T2w = [DataDir '/' Subject '/anat/T1w/T2w_acpc_dc_restore.nii.gz'];
OutDir = [DataDir '/' Subject '/tans'];
    
% run the tans_headmodels function;
%tans_headmodels(Subject,T1w,T2w,OutDir,Paths);

FunctionalNetworks = ft_read_cifti_mod([DataDir '/' Subject '/pfm/Bipartite_PhysicalCommunities+SpatialFiltering.dtseries.nii']);
FunctionalNetworks.data = FunctionalNetworks.data(:,dense_idx); % 0.005
FunctionalNetworks.time = 1;

% isolate the target network
TargetNetwork = FunctionalNetworks;
TargetNetwork.data(TargetNetwork.data~=M1_cluster_idx) = 0; % note: 14 == left motor hand map.
TargetNetwork.data(TargetNetwork.data==M1_cluster_idx) = 1; % binarize.

% load cortical mask representing the lateral PFC;
% SearchSpace = ft_read_cifti_mod('LPFC_LH+RH.dtseries.nii');
% hejieshi :load left M1
if strcmp(hemi, 'lh')
    SearchSpace = ft_read_cifti_mod([DataDir '/' Subject '/pfm/' Subject '_Label_23.dscalar.nii']);
else
    SearchSpace = ft_read_cifti_mod([DataDir '/' Subject '/pfm/' Subject '_Label_57.dscalar.nii']); % 23 left 57 right(m1) |  21 left 55 right(s1)
end
% load sulcal depth information;
Sulc = ft_read_cifti_mod([DataDir '/' Subject '/anat/MNINonLinear/fsaverage_LR32k/' Subject '.sulc.32k_fs_LR.dscalar.nii']);
BrainStructure = SearchSpace.brainstructure; % extract the brain structure index
Sulc.data(BrainStructure==-1) = []; % remove medial wall vertices present in this file.

% define input variables;
MidthickSurfs{1} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.L.midthickness.32k_fs_LR.surf.gii'];
MidthickSurfs{2} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.R.midthickness.32k_fs_LR.surf.gii'];
VertexSurfaceArea = ft_read_cifti_mod([DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.midthickness_va.32k_fs_LR.dscalar.nii']);


OutDir = [DataDir '/' Subject '/tans/ROI_M1'];

% run the tans_roi function
tans_roi(TargetNetwork,MidthickSurfs,VertexSurfaceArea,Sulc,SearchSpace,OutDir,Paths);


FunctionalNetworks = ft_read_cifti_mod([DataDir '/' Subject '/pfm/Bipartite_PhysicalCommunities+SpatialFiltering.dtseries.nii']);
FunctionalNetworks.data = FunctionalNetworks.data(:,dense_idx); % 0.005
FunctionalNetworks.time = 1;

% isolate the target network
TargetNetwork = FunctionalNetworks;
TargetNetwork.data(TargetNetwork.data~=S1_cluster_idx) = 0; % note: 14 == left motor hand map.
TargetNetwork.data(TargetNetwork.data==S1_cluster_idx) = 1; % binarize.

% load cortical mask representing the lateral PFC;
% SearchSpace = ft_read_cifti_mod('LPFC_LH+RH.dtseries.nii');
% hejieshi :load left M1
if strcmp(hemi, 'lh')
    SearchSpace = ft_read_cifti_mod([DataDir '/' Subject '/pfm/' Subject '_Label_21.dscalar.nii']);
else
    SearchSpace = ft_read_cifti_mod([DataDir '/' Subject '/pfm/' Subject '_Label_55.dscalar.nii']); % 23 left 57 right(m1) |  21 left 55 right(s1)
end
% load sulcal depth information;
Sulc = ft_read_cifti_mod([DataDir '/' Subject '/anat/MNINonLinear/fsaverage_LR32k/' Subject '.sulc.32k_fs_LR.dscalar.nii']);
BrainStructure = SearchSpace.brainstructure; % extract the brain structure index
Sulc.data(BrainStructure==-1) = []; % remove medial wall vertices present in this file.

% define input variables;
MidthickSurfs{1} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.L.midthickness.32k_fs_LR.surf.gii'];
MidthickSurfs{2} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.R.midthickness.32k_fs_LR.surf.gii'];
VertexSurfaceArea = ft_read_cifti_mod([DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.midthickness_va.32k_fs_LR.dscalar.nii']);


OutDir = [DataDir '/' Subject '/tans/ROI_S1'];

% run the tans_roi function
tans_roi(TargetNetwork,MidthickSurfs,VertexSurfaceArea,Sulc,SearchSpace,OutDir,Paths);







OutDir = [DataDir '/' Subject '/tans/ROI_M1'];
TargetNetworkPatch = ft_read_cifti_mod([OutDir '/ROI/TargetNetworkPatch.dtseries.nii']);
PialSurfs{1} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.L.pial.32k_fs_LR.surf.gii'];
PialSurfs{2} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.R.pial.32k_fs_LR.surf.gii'];
SkinSurf = [DataDir '/' Subject '/tans/HeadModel/m2m_' Subject '/Skin.surf.gii'];
SearchGridRadius = 20;
GridSpacing = 2;
   
% run the tans_searchgrid function
[SubSampledSearchGrid,FullSearchGrid] = tans_searchgrid(TargetNetworkPatch,PialSurfs,SkinSurf,GridSpacing,SearchGridRadius,OutDir,Paths);
    
 % define inputs
SearchGridCoords = SubSampledSearchGrid;
PialSurfs{1} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.L.pial.32k_fs_LR.surf.gii'];
PialSurfs{2} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.R.pial.32k_fs_LR.surf.gii'];
WhiteSurfs{1} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.L.white.32k_fs_LR.surf.gii'];
WhiteSurfs{2} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.R.white.32k_fs_LR.surf.gii'];
MidthickSurfs{1} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.L.midthickness.32k_fs_LR.surf.gii'];
MidthickSurfs{2} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.R.midthickness.32k_fs_LR.surf.gii'];
MedialWallMasks{1} = [DataDir '/' Subject '/anat/MNINonLinear/fsaverage_LR32k/' Subject '.L.atlasroi.32k_fs_LR.shape.gii'];
MedialWallMasks{2} = [DataDir '/' Subject '/anat/MNINonLinear/fsaverage_LR32k/' Subject '.R.atlasroi.32k_fs_LR.shape.gii'];
SkinSurf = [DataDir '/' Subject '/tans/HeadModel/m2m_' Subject '/Skin.surf.gii'];
HeadMesh = [DataDir '/' Subject '/tans/HeadModel/m2m_' Subject '/' Subject '.msh'];
%     CoilModel = [Paths{1} '/simnibs_env/lib/python3.9/site-packages/simnibs/resources/coil_models/Drakaki_BrainStim_2022/MagVenture_MCF-B65.ccd']; % note: SimNIBS 4.0 seems to require full path, whereas earlier versions did not.
CoilModel = [Paths{1} '/simnibs_env/lib/python3.9/site-packages/simnibs/resources/coil_models/Drakaki_BrainStim_2022/MagVenture_Cool-B70.ccd']; % note: SimNIBS 4.0 seems to require full path, whereas earlier versions did not.
CoilModel = [Paths{1} '/simnibs_env/lib/python3.9/site-packages/simnibs/resources/coil_models/Drakaki_BrainStim_2022/MagVenture_C-B70.ccd']; % note: SimNIBS 4.0 seems to require full path, whereas earlier versions did not.
DistanceToScalp = 2;
AngleResolution = 30;

    
% run the tans_simnibs function
tans_simnibs(SearchGridCoords,HeadMesh,CoilModel,AngleResolution,DistanceToScalp,SkinSurf,MidthickSurfs,WhiteSurfs,PialSurfs,MedialWallMasks,nThreads,OutDir,Paths);    
    
    
% define inputs
PialSurfs{1} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.L.pial.32k_fs_LR.surf.gii'];
PialSurfs{2} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.R.pial.32k_fs_LR.surf.gii'];
WhiteSurfs{1} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.L.white.32k_fs_LR.surf.gii'];
WhiteSurfs{2} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.R.white.32k_fs_LR.surf.gii'];
MidthickSurfs{1} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.L.midthickness.32k_fs_LR.surf.gii'];
MidthickSurfs{2} = [DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.R.midthickness.32k_fs_LR.surf.gii'];
VertexSurfaceArea = ft_read_cifti_mod([DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.midthickness_va.32k_fs_LR.dscalar.nii']);
MedialWallMasks{1} = [DataDir '/' Subject '/anat/MNINonLinear/fsaverage_LR32k/' Subject '.L.atlasroi.32k_fs_LR.shape.gii'];
MedialWallMasks{2} = [DataDir '/' Subject '/anat/MNINonLinear/fsaverage_LR32k/' Subject '.R.atlasroi.32k_fs_LR.shape.gii'];
%     SearchGrid = [DataDir '/' Subject '/tans/Network_Frontoparietal/SearchGrid/SubSampledSearchGrid.shape.gii'];
SearchGrid = [DataDir '/' Subject '/tans/ROI_M1/SearchGrid/SubSampledSearchGrid.shape.gii'];
SkinFile = [DataDir '/' Subject '/tans/HeadModel/m2m_' Subject '/Skin.surf.gii'];
HeadMesh = [DataDir '/' Subject '/tans/HeadModel/m2m_' Subject '/' Subject '.msh'];
%     OutDir = [DataDir '/' Subject '/tans/Network_Frontoparietal/'];
OutDir = [DataDir '/' Subject '/tans/ROI_M1/'];
PercentileThresholds = linspace(99.9,99,10);
    % CoilModel = [Paths{1} '/simnibs_env/lib/python3.9/site-packages/simnibs/resources/coil_models/Drakaki_BrainStim_2022/MagVenture_C-B70.ccd']; % note: SimNIBS 4.0 seems to require full path, whereas earlier versions did not.
DistanceToScalp = 2;
Uncertainty = 5;
AngleResolution = 5;
    
%     % isolate the target network again
%     TargetNetwork = FunctionalNetworks;
%     TargetNetwork.data(TargetNetwork.data~=3 & TargetNetwork.data~=28) = 0; % note: 14 == left motor hand map.
%     TargetNetwork.data(TargetNetwork.data==3 | TargetNetwork.data==28) = 1; % binarize.

TargetNetworkPatchM1 = ft_read_cifti_mod([OutDir '/ROI/TargetNetworkPatch.dtseries.nii']);
TargetNetworkPatchS1 = ft_read_cifti_mod([DataDir '/' Subject '/tans/ROI_S1/ROI/TargetNetworkPatch.dtseries.nii']);
    
tans_optimize_new(Subject,TargetNetworkPatchM1,TargetNetworkPatchS1,[],PercentileThresholds,SearchGrid,DistanceToScalp,SkinSurf,VertexSurfaceArea,MidthickSurfs,WhiteSurfs,PialSurfs,MedialWallMasks,HeadMesh,AngleResolution,Uncertainty,CoilModel,OutDir,Paths);   
    
