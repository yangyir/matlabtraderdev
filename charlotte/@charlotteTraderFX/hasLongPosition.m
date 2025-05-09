function [ret,trade] = hasLongPosition(obj,code,varargin)
    % a charlotteTraderFX function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('status','set',@ischar);
    p.addParameter('closedt','',@ischar);
    
    p.parse(varargin{:});
    status = p.Results.status;
    closedt = p.Results.closedt;
    
    n = obj.book_.latest_;
    ret = false;
    trade = [];
    for i = 1:n
        trade_i = obj.book_.node_(i);
        if isempty(closedt)
            closedtflag = true;
        else
            closedtflag = strcmpi(trade_i.closedatetime2_,closedt);
        end
        
        if strcmpi(trade_i.code_,code) && trade_i.opendirection_ == 1 && strcmpi(trade_i.status_,status) && closedtflag
            ret = true;
            trade = trade_i;
            break
        end
    end
end