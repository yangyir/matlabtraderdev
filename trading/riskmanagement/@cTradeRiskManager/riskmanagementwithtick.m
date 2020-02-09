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
    doprint = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    
    unwindtrade = {};
    
    if isempty(tick), return; end
    tickTime = tick(1);
    tickBid = tick(2);
    tickAsk = tick(3);
%     tickTrade = tick(4);
    
    %skip this if the tick time happend in the past, this might be used in
    %the replay mode
    if tickTime <= obj.trade_.opendatetime1_, return; end
    
    %skip this in case the trade is closed
    if strcmpi(obj.trade_.status_,'closed'), return; end
    
    %skip this in case the risk manager is closed
    if strcmpi(obj.status_,'closed'), return; end
    
    %1.check whether either 1) stop loss is breached or 2) target is
    %breached
    if (obj.trade_.opendirection_ == 1 && tickBid < obj.pxstoploss_) ||...
            (obj.trade_.opendirection_ == -1 && tickAsk > obj.pxstoploss_ ) ||...
            (obj.trade_.opendirection_ == 1 && tickBid > obj.pxtarget_) || ...
            (obj.trade_.opendirection_ == -1 && tickAsk < obj.pxtarget_)
        obj.status_ = 'closed';
        obj.trade_.status_ = 'closed';
        
        if strcmpi(class(obj),'cBatman'), obj.checkflag_ = 0;end
        
        unwindtrade = obj.trade_;
        
        if doprint
            if (obj.trade_.opendirection_ == 1 && tickBid < obj.pxstoploss_) || ...
                    (obj.trade_.opendirection_ == -1 && tickAsk > obj.pxstoploss_ )
                fprintf('%s:%s closed as tick price breaches stoploss price at %s...\n',...
                    datestr(tickTime,'yyyy-mm-dd HH:MM:SS'),...
                    class(obj),...
                    num2str(obj.pxstoploss_));
            elseif (obj.trade_.opendirection_ == 1 && tickBid > obj.pxtarget_) || ...
                    (obj.trade_.opendirection_ == -1 && tickAsk < obj.pxtarget_)
                fprintf('%s:%s closed as tick price breaches target price at %s...\n',...
                    datestr(tickTime,'yyyy-mm-dd HH:MM:SS'),...
                    class(obj),...
                    num2str(obj.pxtarget_));
            end
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
        return
    else
        if obj.trade_.opendirection_ == 1
            obj.trade_.runningpnl_ = obj.trade_.openvolume_*(tickBid-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
        else
            obj.trade_.runningpnl_ = -obj.trade_.openvolume_*(tickAsk-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
        end
    end
    
    %2.check with time stop if it is necessary
    if ~isempty(obj.trade_.stopdatetime1_) && obj.trade_.stopdatetime1_ < tickTime
        obj.status_ = 'closed';
        obj.trade_.status_ = 'closed';
        
        if strcmpi(class(obj),'cBatman')
            obj.checkflag_ = 0;
        end
        
        unwindtrade = obj.trade_;
        
        if doprint
            fprintf('%s:%s closed as time breaches stop time at %s...\n',...
                datestr(tickTime,'yyyy-mm-dd HH:MM:SS'),...
                class(oj),...
                obj.trade_.stopdatetime2_);
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
        
        return
    end
    
end