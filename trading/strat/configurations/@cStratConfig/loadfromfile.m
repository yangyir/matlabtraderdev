function [] = loadfromfile( obj, varargin )
%cStratConfig
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('filename','',@ischar);
p.addParameter('code','',@ischar);
p.parse(varargin{:});

code = p.Results.code;
if isempty(code), error([class(obj),':loadfromfile:invalid code input']); end

filename = p.Results.filename;
if isempty(filename), error([class(obj),':loadfromfile:invalid filename input']);end


fid = fopen(filename,'r');
tline = fgetl(fid);
lineinfo = regexp(tline,'\t','split');
n = size(lineinfo,2) - 1;
propnames = cell(100,1);
propvalues = cell(100,n);
count = 0;
coderow = 0;
codecol = 0;
while ischar(tline)
    count = count + 1;
    lineinfo = regexp(tline,'\t','split');
    propnames{count} = lineinfo{1};
    if strcmpi(propnames{count},'CodeCTP')
        coderow = count;
    end
    for i = 2:size(lineinfo,2)
        propvalues{count,i-1} = lineinfo{i};
        if strcmpi(propvalues{count,i-1},code)
            codecol = i-1;
        end
    end
    tline = fgetl(fid);
end

if coderow == 0 || codecol == 0
     error([class(obj),':loadfromfile:either CodeCTP row or column with ',code,' not found'])
end

propnames = propnames(1:count);
propvalues = propvalues(1:count,1:n);
fclose(fid);


for i = 1:count
    val = propvalues{i,codecol};
    if isnumchar(val), val = str2double(val); end
    obj.([lower(propnames{i}),'_']) = val;
end

end

