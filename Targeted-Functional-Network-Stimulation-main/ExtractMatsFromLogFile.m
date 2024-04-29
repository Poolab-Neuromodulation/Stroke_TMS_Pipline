function [Output] = ExtractMatsFromLogFile(File)

% setup the import Options
opts = delimitedTextImportOptions("NumVariables", 1);

% specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = "";

% specify column names and types
opts.VariableTypes = "char";
opts = setvaropts(opts, 1, "WhitespaceRule", "preserve");
opts = setvaropts(opts, 1, "EmptyFieldRule", "auto");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
Log = readtable(File, opts);

% preallocate
count = 0;

% sweep the lines
% of the log file;
for i = 1:size(Log,1)
    
    tmp = table2cell(Log(i,:));
    tmp = tmp{1};
    
    % if this line represents the first 
    % line of an affine transformation matrix 
    if ~isempty(tmp) && strcmp(tmp(1:2),'[[') 
        
        Idx = i:i+3; % these rows correspond to matrix i
        tmp = table2array(Log(Idx,:));
        tmp = strrep(tmp,'[','');
        tmp = strrep(tmp,']','');
        
        % preallocate;
        m = zeros(4);
        
        % sweep
        % the rows;
        for ii = 1:4
            m(ii,:) = str2num(tmp{ii,1});
        end
        
        % log the matrix
        count = count + 1;
        Output{count} = m;
        
    end
    
end
