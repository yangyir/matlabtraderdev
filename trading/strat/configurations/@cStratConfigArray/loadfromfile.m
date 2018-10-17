function [] = loadfromfile( obj, varargin )
%cStratConfigArray
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('filename','',@ischar);
p.addParameter('codelist',{},@iscell);
p.parse(varargin{:});

filename = p.Results.filename;
if isempty(filename), error([class(obj),':loadfromfile:invalid filename input']);end

codelist = p.Results.codelist;

fid = fopen(filename,'r');
tline = fgetl(fid);
lineinfo = regexp(tline,'\t','split');
n = size(lineinfo,2) - 1;
foundCodeCTP = false;
foundName = false;
while ischar(tline)
    lineinfo = regexp(tline,'\t','split');
    propname = lineinfo{1};
    if strcmpi(propname,'CodeCTP')
        foundCodeCTP = true;
        codelistfromfile = lineinfo;
%         break
    end
    %
    if strcmpi(propname,'Name')
        foundName = true;
        namelistfromfile = lineinfo;
    end

    tline = fgetl(fid);
end
fclose(fid);

if ~foundCodeCTP, error([class(obj),':loadfromfile:CodeCTP not found']); end
if ~foundName, error([class(obj),':loadfromfile:Name not found']); end

if isempty(codelist)
    for icode = 2:length(codelistfromfile)
%         config_i = feval(class(obj.node_));
        config_i = feval(namelistfromfile{icode});
        config_i.loadfromfile('code',codelistfromfile{icode},'filename',filename);
        if ~obj.hasconfig(config_i)
            obj.push(config_i);
        end
    end
else
    ncode = length(codelist);
    for icode = 1:ncode
        foundi = false;
        for icol = 1:n
            if strcmpi(codelist{icode},codelistfromfile{icol+1})
                foundi = true;
                break
            end
        end
        if ~foundi
            fprintf('%s:loadfromfile:%s not found in file\n',class(obj),codelist{icode});
            continue;
        else
            config_i = feval(class(obj.node_));
            config_i.loadfromfile('code',codelist{icode},'filename',filename);
            if ~obj.hasconfig(config_i)
                obj.push(config_i);
            end
        end
        
    end
end


end

