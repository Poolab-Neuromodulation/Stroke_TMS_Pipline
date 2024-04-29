function spatial_filtering_split_label(Input,OutDir,Subject)

% read in input and 
% preallocate output cifti;
Input = ft_read_cifti_mod(Input);
O = Input; O.data = zeros(size(Input.data)); % blank slate;

% sweep through the graph densities
for s = 1:size(Input.data,2)
    
    A = Input; % preallocate
    A.data = Input.data(:,s);
    
    % define the unique communities;
    uCi = unique(nonzeros(A.data(:,1)));
    
    % sweep communities;
    for i = 1:length(uCi)
        
        B = A; % preallocate;
        
        % set all other
        % communities to zero;
        B.data(B.data~=uCi(i)) = 0;
        B.data(B.data~=0) = 1;
        
        % write out temporary CIFTI;
        ft_write_cifti_mod([OutDir '/' Subject '_Label_' num2str(i)],B, 'parameter', 'dlabel', 'datatype', 'dense_label');
        
        
    end
    
    
end


end