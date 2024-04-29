% function [uClusters, res]=fiber_in_cluster(DataDir,Subject,hemi,cluster_dir,fiber_dir,output_path)

% DataDir = ['/home/poolab/HDD_4T/Stroke_data/Patient_data/multi_echo'];
% Subject = 'ME18';
% hemi = 'rh';


Subdir = [DataDir '/' Subject];
cd([Subdir '/pfm']);
mkdirp([Subdir '/pfm/aparc_32k_label']);
aparc_32k_label_path = [Subdir '/anat/MNINonLinear/fsaverage_LR32k/' Subject '.aparc.32k_fs_LR.dlabel.nii'];
spatial_filtering_split_label(aparc_32k_label_path,[Subdir '/pfm/aparc_32k_label'],Subject);
system(['cp ' Subdir '/pfm/aparc_32k_label/' Subject '_Label_23.dscalar.nii ' Subdir '/pfm/']);
system(['cp ' Subdir '/pfm/aparc_32k_label/' Subject '_Label_57.dscalar.nii ' Subdir '/pfm/']);
system(['cp ' Subdir '/pfm/aparc_32k_label/' Subject '_Label_21.dscalar.nii ' Subdir '/pfm/']);
system(['cp ' Subdir '/pfm/aparc_32k_label/' Subject '_Label_55.dscalar.nii ' Subdir '/pfm/']);
FunctionalNetworks = ft_read_cifti_mod([DataDir '/' Subject '/pfm/Bipartite_PhysicalCommunities+SpatialFiltering.dtseries.nii']);
FunctionalNetworks.data = FunctionalNetworks.data(:,cluster_idx);



% cluster_dir = './M1_clusters.dtseries.nii';
% fiber_dir = './L_active_CST_R_1e-3.tck';

voxel_size = 1;
if strcmp(hemi, 'rh')
    Hemihemi = 'CORTEX_RIGHT';
    Hemisphere = 'R';
    brainlabel = 2;
    M1_label = '57';
    S1_label = '55';
    fiber_dir = [Subdir '/dti/L_active_CST_R_1e-3.tck'];
elseif strcmp(hemi, 'lh')
    Hemihemi = 'CORTEX_LEFT';
    Hemisphere = 'L';
    brainlabel = 1;
    M1_label = '23';
    S1_label = '21';
    fiber_dir = [Subdir '/dti/R_active_CST_L_1e-3.tck'];
end

% auto
fiber_dir = [Subdir '/dti/CST_right_auto.tck'];


SearchSpace = ft_read_cifti_mod([DataDir '/' Subject '/pfm/' Subject '_Label_' M1_label '.dscalar.nii']); % 23 left 57 right(m1) | 21 left 55 right(s1)
FunctionalNetworks.data(SearchSpace.data==0) = 0; % constrain to search space
ft_write_cifti_mod([Subdir '/pfm/M1_TargetNetwork'],FunctionalNetworks); % write out the .dtseries.nii;

FunctionalNetworks = ft_read_cifti_mod([DataDir '/' Subject '/pfm/Bipartite_PhysicalCommunities+SpatialFiltering.dtseries.nii']);
FunctionalNetworks.data = FunctionalNetworks.data(:,cluster_idx);
SearchSpace = ft_read_cifti_mod([DataDir '/' Subject '/pfm/' Subject '_Label_' S1_label '.dscalar.nii']); % 23 left 57 right(m1) | 21 left 55 right(s1)
FunctionalNetworks.data(SearchSpace.data==0) = 0; % constrain to search space
ft_write_cifti_mod([Subdir '/pfm/S1_TargetNetwork'],FunctionalNetworks); % write out the .dtseries.nii;



PIAL=[DataDir '/' Subject '/anat/T1w/Native/' Subject '.' Hemisphere '.pial.native.surf.gii'];
WHITE=[DataDir '/' Subject '/anat/T1w/Native/' Subject '.' Hemisphere '.white.native.surf.gii'];
REG_MSMSulc= [DataDir '/' Subject '/anat/MNINonLinear/Native/' Subject '.' Hemisphere '.sphere.MSMSulc.native.surf.gii'];
REG_MSMSulc_FSLR32k=[DataDir '/' Subject '/anat/MNINonLinear/fsaverage_LR32k/' Subject '.' Hemisphere '.sphere.32k_fs_LR.surf.gii'];
MIDTHICK=[DataDir '/' Subject '/anat/T1w/Native/' Subject '.' Hemisphere '.midthickness.native.surf.gii'];
MIDTHICK_FSLR32k=[DataDir '/' Subject '/anat/T1w/fsaverage_LR32k/' Subject '.' Hemisphere '.midthickness.32k_fs_LR.surf.gii'];
ROI_FSLR32k=[DataDir '/' Subject '/anat/MNINonLinear/fsaverage_LR32k/' Subject '.' Hemisphere '.atlasroi.32k_fs_LR.shape.gii'];


for j = 1:2
    if j == 1
        target = 'M1';
    elseif j == 2
        target = 'S1';
    end


cluster_dir = [Subdir '/pfm/' target '_TargetNetwork.dtseries.nii'];



fiber = dtiImportFibersMrtrix(fiber_dir);
cluster = ft_read_cifti_mod(cluster_dir);


% 
% % extract coordinates for all cortical vertices 
BrainStructure = cluster.brainstructure; % barrow the brain structure index
CortexRightIdx = BrainStructure == brainlabel;

cluster_data = cluster.data(CortexRightIdx,:);
uClusters = unique(nonzeros(cluster_data));
tmpCluster = cluster;

res = int16.empty;

% res2 = struct();
for i = 1:size(uClusters,1)
    tmpCluster.data = cluster.data;
    tmpCluster.data(tmpCluster.data ~= uClusters(i)) = 0;
    ft_write_cifti_mod('./tmp.dtseries.nii',tmpCluster);
    res(i) = 0;
    system(['wb_command -cifti-separate ./tmp.dtseries.nii COLUMN -metric ' Hemihemi ' ./task.32k_fs_LR.shape.gii']);
    system(['wb_command -metric-resample ./task.32k_fs_LR.shape.gii ' REG_MSMSulc_FSLR32k ' ' REG_MSMSulc ' ADAP_BARY_AREA ./task.native.shape.gii -area-surfs ' MIDTHICK_FSLR32k ' ' MIDTHICK ' -current-roi ' ROI_FSLR32k]);
    system(['wb_command -metric-to-volume-mapping ./task.native.shape.gii ' MIDTHICK ' ' DataDir '/' Subject '/anat/T1w/T1w_acpc_dc_restore_brain.nii.gz ./task.native.nii.gz -ribbon-constrained ' WHITE ' ' PIAL]);
    system(['fslmaths ./task.native.nii.gz -thr 0 -bin ./task.ROI' num2str(uClusters(i)) '.native.nii.gz']);
    system('rm ./task.32k_fs_LR.shape.gii');
    system('rm ./task.native.shape.gii');
    system('rm ./tmp.dtseries.nii');
    system('rm ./task.native.nii.gz');
    try 
        roi_nii = nifti_load(['./task.ROI' num2str(uClusters(i)) '.native.nii.gz']);
    catch
        continue
    end
    nii_idx = find(roi_nii.vol>0);
    if isempty(nii_idx)
        system(['rm ./task.ROI' num2str(uClusters(i)) '.native.nii.gz']);
        continue
    end
    [x,y,z] = ind2sub(size(roi_nii.vol), nii_idx);
    nii_coord = [x y z];
    rzs = [roi_nii.srow_x(1:3) roi_nii.srow_y(1:3) roi_nii.srow_z(1:3)];
    trans = [roi_nii.srow_x(4) roi_nii.srow_y(4) roi_nii.srow_z(4)];
    ras_coord = nii_coord * rzs + trans;
    ras_coord = [ras_coord(:,1) ras_coord(:,2) ras_coord(:,3)];

    for ii = 1:size(fiber.fibers,1)
        fb = fiber.fibers(ii);
        fb = fb{1}.';
        dist = pdist2(fb, ras_coord, 'euclidean');
        if min(dist, [], "all") < 1.5 * voxel_size
            res(i) = res(i) + 1;
        end
    end
    system(['rm ./task.ROI' num2str(uClusters(i)) '.native.nii.gz']);
end

[sorted, idx] = sort(res, 'descend');
Cluster_index = uClusters(idx(sorted~=0));
Fiber_Number = sorted(sorted~=0).';
T = table(Cluster_index, Fiber_Number);
writetable(T, [Subdir '/pfm/' target '_fiber.txt'], 'Delimiter', '\t', 'WriteRowNames', true);

% [val, idx] = max(res);
% tmpCluster.data = cluster.data;
% tmpCluster.data(tmpCluster.data ~= uClusters(idx)) = 0;
% ft_write_cifti_mod(output_path,tmpCluster);

end

