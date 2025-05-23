function [ret,trade] = hasLongPosition(obj,code,freq,varargin)
    % a charlotteTraderFX function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('direction',1,@isnumeric);
    p.addParameter('status','set',@ischar);
    p.addParameter('closedt','',@ischar);
    
    p.parse(varargin{:});
    status = p.Results.status;
    closedt = p.Results.closedt;
    direction = p.Results.direction;
    if ~(direction == 1 || direction == 2)
        error('invalid direction input')
    end
    
    
    ret = false;
    trade = [];
    if direction == 1
        n = obj.book_.latest_;
        for i = 1:n
            trade_i = obj.book_.node_(i);
            if isempty(closedt)
                closedtflag = true;
            else
                closedtflag = strcmpi(trade_i.closedatetime2_,closedt);
            end

            if strcmpi(trade_i.code_,code) && strcmpi(trade_i.opensignal_.frequency_,freq) && trade_i.opendirection_ == direction && strcmpi(trade_i.status_,status) && closedtflag
                ret = true;
                trade = trade_i;
                break
            end
        end
    elseif direction == 2
        n = obj.pendingbook_.latest_;
        for i = 1:n
            trade_i = obj.pendingbook_.node_(i);
            if isempty(closedt)
                closedtflag = true;
            else
                closedtflag = strcmpi(trade_i.closedatetime2_,closedt);
            end

            if strcmpi(trade_i.code_,code) && strcmpi(trade_i.opensignal_.frequency_,freq) && trade_i.opendirection_ == direction && strcmpi(trade_i.status_,status) && closedtflag
                ret = true;
                trade = trade_i;
                break
            end
        end
    end
end