function [unwindtrade] = riskmanagementwithtick(obj,tick,varargin)
%optional input control variables:
%   Debug:print log on the screen

%   UpdatePnLForClosedTrade:TRUE means computing closed pnl for unwinded
%   trades. Default value is FALSE as risk manager doesn't have the
%   authorities to close positions while he can only inform the trader or
%   strat to do so. At this point, we are not guaranteed that the trade is
%   closed as per risk management requirement. However, we can use TRUE for
%   replay purposes.

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Debug',false,@islogical)
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.parse(varargin{:});
    debug = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    
    unwindtrade = {};
    
    tickTime = tick(1);
    tickBid = tick(2);
    tickAsk = tick(3);
    tickTrade = tick(4);
    
    if tickTime <= obj.trade_.opendatetime1_, return; end
    
    if (obj.trade_.opendirection_ == 1 && tickTrade < obj.pxstoploss_) ||...
            (obj.trade_.opendirection == -1 && tickTrade > obj.pxstoploss_ )
        obj.status_ = 'closed';
        obj.checkflag_ = 0;
        unwindtrade = obj.trade_;
        if debug
            fprintf('%s:batman closed as tick price breaches stoploss price at %s...\n',...
                datestr(tickTime,'yyyy-mm-dd HH:MM'),...
                num2str(obj.pxstoploss_));            
        end
        %
        if updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            if obj.trade_.opendirection_ == 1
                obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(tickBid-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
                obj.trade_.closeprice_ = tickBid;
            else
                obj.trade_.closepnl_ = obj.trade_.opendirection_*obj.trade_.openvolume_*(tickAsk-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
                obj.trade_.closeprice_ = tickAsk;
            end
            obj.trade_.closedatetime1_ = tickTime;
            obj.trade_.closedatetime2_ = datestr(obj.trade_.closedatetime1_,'yyyy-mm-dd HH:MM:SS');
        end
    end
    
end