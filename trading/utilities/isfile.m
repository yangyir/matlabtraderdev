function [flag,output] = isfile(fileName,varargin)
%isfile determine whether the input fileName exists
%input fileName shall contain the full path
%e.g.'C:\temp\file'
p = inputParser;
p.CaseSensitive = false;
p.KeepUnmatched = false;
p.addRequired('fileName',@ischar);
p.addOptional('fileFormat','.mat',@ischar);
p.parse(fileName,varargin{:});
fileName = p.Results.fileName;
fileFormat = p.Results.fileFormat;
fileName = [fileName,fileFormat];

try
    % load data from existing .mat file
    output = importdata(fileName);
    flag = 1;
catch err
    flag = 0;
    output = {};
%     fprintf(['isfile:',err.message,'\n']);
end
    
end

