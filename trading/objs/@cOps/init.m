function [obj] = init(obj,varargin)
%cOps
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('name','ops',@ischar);
    p.parse(varargin{:});
    obj.name_ = p.Results.name;
    obj.entrusts_ = EntrustArray;
    obj.entrustspending_ = EntrustArray;
    obj.entrustsfinished_ = EntrustArray;
    obj.trades_ = cTradeOpenArray;
    %
    obj.settimerinterval(1);
    obj.printflag_ = true;
    obj.print_timeinterval_ = 60;
    obj.fileioflag_ = true;
    

end