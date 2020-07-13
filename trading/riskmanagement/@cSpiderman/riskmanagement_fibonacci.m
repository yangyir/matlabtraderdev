function [ unwindtrade ] = riskmanagement_fibonacci( obj,varargin )
%cSpiderman
    unwindtrade = {};
    if strcmpi(obj.trade_.status_,'closed'), return; end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ExtraInfo',{},@isstruct);
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.parse(varargin{:});
    extrainfo = p.Results.ExtraInfo;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    
    trade = obj.trade_;
    direction = trade.opendirection_;
    closeflag = 0;
    
    if direction == 1
        if extrainfo.p(end,5) < obj.fibonacci1_-0.618*(obj.fibonacci1_-obj.fibonacci0_)
            closeflag = 1;
        end
    else
        if extrainfo.p(end,5) > obj.fibonacci0_+0.618*(obj.fibonacci1_-obj.fibonacci0_)
            closeflag = 1;
        end
    end
    
    if closeflag
        obj.status_ = 'closed';
        obj.closestr_ = 'fibonacci:0.618';
        unwindtrade = obj.trade_;
        if updatepnlforclosedtrade
            trade.status_ = 'closed';
            trade.runningpnl_ = 0;
            if isempty(trade.instrument_)
                trade.closepnl_ = direction*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_);
            else
                trade.closepnl_ = direction*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
            end
            trade.closedatetime1_ = extrainfo.p(end,1);
            trade.closeprice_ = extrainfo.p(end,5);
        end
        return
    end
    
    if strcmpi(trade.opensignal_.frequency_,'daily')
        idxstart2check = find(extrainfo.p(:,1)>=trade.opendatetime1_,1,'first')+1;
    else
        idxstart2check = find(extrainfo.p(:,1)<=trade.opendatetime1_,1,'last')-1;
    end
    
    if strcmpi(obj.type_,'breachup-B')
        obj.fibonacci1_ = max(extrainfo.p(idxstart2check:end,3));
        obj.fibonacci0_ = max(extrainfo.ll(idxstart2check:end));
        
        
    elseif strcmpi(obj.type_,'breachdn-S')
        obj.fibonacci0_ = min(extrainfo.p(idxstart2check:end,4));
        obj.fibonacci1_ = min(extrainfo.ll(idxstart2check:end)); 
    end
    
    

end

