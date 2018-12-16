function [] = unwindall(obj,varargin)
%cStrat
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.parse(varargin{:});
    
    try
        ntrades = obj.helper_.trades_.lastest_;
    catch
        ntrades = 0;
    end
    
    for itrade = 1:ntrades
        trade_i = obj.helper_.trades_.node_(itrade);
        if ~strcmpi(trade_i.status,'closed')
            obj.unwindtrade(trade_i);
        end
    end
    
    
end