function [] = loadtickdata(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('fn','',@ischar);
    p.parse(varargin{:});
    codestr = p.Results.code;
    fn = p.Results.fn;
    
    [flag,idx] = obj.instruments_.hasinstrument(codestr);
    if ~flag
        obj.registerinstrument(codestr);
        idx = obj.instruments_.count;
    end
    
    try
        if ~isempty(strfind(fn,'.txt'))
            d = cDataFileIO.loadDataFromTxtFile(fn);
        elseif ~isempty(strfind(fn,'.mat'))
            d = load(fn);
        end
        if isstruct(d)
            flds = fields(d);
%             data = getfield(d,flds{1});
            data = d.(flds{1});
            obj.tickdata_{idx} = data;
        else
            obj.tickdata_{idx} = d;
        end
    catch e
        fprintf([e.message,'\n']);
    end
    
end