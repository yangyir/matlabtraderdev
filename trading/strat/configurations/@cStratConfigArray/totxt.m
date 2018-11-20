function [ret] = totxt(obj,varargin)
%cStratConfigArray
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('filename','',@ischar);
p.parse(varargin{:});
filename = p.Results.filename;
if isempty(filename), error([class(obj),':totxt:invalid filename input']);end

[configtbl,colnames] = obj.totable;

fid = fopen(filename,'w');
nrows = size(configtbl,1);
for i = 1:length(colnames)
    if strcmpi(colnames{i},'instrument_'), continue; end
    propname = colnames{i}(1:end-1);
    fprintf(fid,'%s',propname);
    for j = 2:nrows
        propvalue = configtbl{j,i};
        if ischar(propvalue)
            fprintf(fid,'\t%s',propvalue);
        else
            fprintf(fid,'\t%s',num2str(propvalue));
        end
    end
    fprintf(fid,'\n');
    
end
fclose(fid);
ret = 1;

end