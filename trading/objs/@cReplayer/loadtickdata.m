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
            data_timevec = zeros(size(data,1),1);
            date_start = floor(data(1,1));
            for i = 1:size(data,1)
                date_i = floor(data(i,1));
                if date_i == date_start
                    data_timevec(i) = 3600*hour(data(i,1))+60*minute(data(i,1))+second(data(i,1));
                else
                    data_timevec(i) = 3600*hour(data(i,1))+60*minute(data(i,1))+second(data(i,1))+86400;
                end
            end
            obj.ticktimevec_{idx,1} = data_timevec;
        else
            obj.tickdata_{idx} = d;
            data_timevec = zeros(size(d,1),1);
            date_start = floor(d(1,1));
            for i = 1:size(d,1)
                date_i = floor(d(i,1));
                if date_i == date_start
                    data_timevec(i) = 3600*hour(d(i,1))+60*minute(d(i,1))+second(d(i,1));
                else
                    data_timevec(i) = 3600*hour(d(i,1))+60*minute(d(i,1))+second(d(i,1))+86400;
                end
            end
            obj.ticktimevec_{idx,1} = data_timevec;
            
        end
    catch e
        fprintf([e.message,'\n']);
    end
    
end