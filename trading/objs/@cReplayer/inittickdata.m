function [] = inittickdata(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','all',@ischar);
    p.addParameter('startdate',{},...
        @(x) validateattributes(x,{'char','numeric'},{},'','startdate'));
    p.addParameter('enddate',{},...
        @(x) validateattributes(x,{'char','numeric'},{},'','enddate'));
    p.parse(varargin{:});
    codestr = p.Results.code;
    startdt = p.Results.startdate;
    enddt = p.Results.enddate;
    
    if isempty(startdt)
        startdt = [datestr(getlastbusinessdate,'yyyy-mm-dd'),' 09:00:00'];
    end
    
    if isempty(enddt)
        enddt = [datestr(datenum(startdt,'yyyy-mm-dd'),'yyyy-mm-dd'),' 15:00:00'];
    end
    
    
    if ~strcmpi(codestr,'all')
        [flag,idx] = obj.instruments_.hasinstrument(codestr);
        if ~flag
            obj.registerinstrument(codestr);
            idx = obj.instruments_.count;
        end
        
        code_bbg = obj.instruments_.getinstrument{idx}.code_bbg;
        try
            c = bbgconnect;
            d = c.timeseries(code_bbg,{startdt,enddt},[],'trade');
            obj.tickdata_{idx} = cell2mat(d(:,2:4));
            c.close;
        catch e
            fprintf([e.message,'\n']);
            c.close;
        end
        
        return
    end
    
    %strcmpi(codestr,all')
    try
        c = bbgconnect;
    catch e
        fprintf([e.message,'\n']);
        return
    end
    
    n = obj.instruments_.count;
    for i = 1:n
        code_bbg = obj.instruments_.getinstrument{i}.code_bbg;
        d = c.timeseries(code_bbg,{startdt,enddt},[],'trade');
        obj.tickdata_{i} = cell2mat(d(:,2:4));
    end
    c.close;
    
end