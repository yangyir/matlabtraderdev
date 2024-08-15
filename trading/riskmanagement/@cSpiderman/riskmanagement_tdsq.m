function [ unwindtrade ] = riskmanagement_tdsq( obj,varargin )
%cSpiderman method
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
    
    closeflag = tdsq_riskmanagement( trade,extrainfo );
       
    if closeflag
        obj.status_ = 'closed';
        unwindtrade = trade;
        if updatepnlforclosedtrade
%             trade.status_ = 'closed';
            trade.runningpnl_ = 0;
            if isempty(trade.instrument_)
                trade.closepnl_ = trade.opendirection_*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_);
            else
                trade.closepnl_ = trade.opendirection_*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
            end
            if strcmpi(trade.riskmanager_.closestr_,'tdsq:perfectss9') || ...
                    strcmpi(trade.riskmanager_.closestr_,'tdsq:perfectbs9') || ...
                    strcmpi(trade.riskmanager_.closestr_,'tdsq:ssbreak') || ...
                    strcmpi(trade.riskmanager_.closestr_,'tdsq:bsbreak')
                trade.closedatetime1_ = extrainfo.p(end,1);
                trade.closeprice_ = extrainfo.p(end,5);
            else
                try
                    trade.closedatetime1_ = extrainfo.latestdt;
                catch
                    trade.closedatetime1_ = extrainfo.p(end,1);
                end
                try
                    trade.closeprice_ = extrainfo.latestopen;
                catch
                    trade.closeprice_ = extrainfo.p(end,5);
                end
            end
        end
    end
    

end

