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

[propnames,propvalues] = getpropnamevaluefromfile(filename);
[m,n] = size(propvalues);
coderow = 0;
codecol = 0;
for i = 1:m
    if strcmpi(propnames{i},'CodeCTP')
        coderow = i;
        for j = 1:n
            if strcmpi(propvalues{i,j},code)
                codecol = j;
            end
        end
    end
end
if coderow == 0 || codecol == 0
     error([class(obj),':loadfromfile:either CodeCTP row or column with ',code,' not found'])
end


for i = 1:m
    val = propvalues{i,codecol};
    valnum = str2double(val);
    if isnan(valnum)
        obj.([lower(propnames{i}),'_']) = val;
    else
        obj.([lower(propnames{i}),'_']) = valnum;
    end
    
end

end

