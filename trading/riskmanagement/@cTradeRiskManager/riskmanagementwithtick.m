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
    
    instrument = obj.trade_.instrument_;
    try
        ticksize = instrument.tick_size;
    catch
        ticksize = 0;
    end
    %1.check whether either 1) stop loss is breached or 2) target is
    %breached
    if (obj.trade_.opendirection_ == 1 && tickBid - obj.pxstoploss_ <= -ticksize ) ||...
            (obj.trade_.opendirection_ == -1 && tickAsk - obj.pxstoploss_ >= ticksize)
%             (obj.trade_.opendirection_ == 1 && tickBid > obj.pxtarget_) || ...
%             (obj.trade_.opendirection_ == -1 && tickAsk < obj.pxtarget_)
        
        ismarketopen = istrading(tickTime,instrument.trading_hours,'tradingbreak',instrument.trading_break);
        if ismarketopen
%             if (obj.trade_.opendirection_ == 1 && tickBid - obj.pxstoploss_ < -instrument.tick_size) || ...
%                     (obj.trade_.opendirection_ == -1 && tickAsk - obj.pxstoploss_ > instrument.tick_size)
                obj.closestr_ = 'tick breaches stoploss price';
                if doprint
                    fprintf('%s:%s:%s of %s...\n',...
                        datestr(tickTime,'yyyy-mm-dd HH:MM:SS'),...
                        class(obj),...
                        obj.closestr_,...
                        num2str(obj.pxstoploss_));
                end
%             elseif (obj.trade_.opendirection_ == 1 && tickBid > obj.pxtarget_) || ...
%                         (obj.trade_.opendirection_ == -1 && tickAsk < obj.pxtarget_)
%                 obj.closestr_ = 'tick breaches target price';
%                 if doprint
%                     fprintf('%s:%s:%s of %s...\n',...
%                         datestr(tickTime,'yyyy-mm-dd HH:MM:SS'),...
%                         class(obj),...
%                         obj.closestr_,...
%                         num2str(obj.pxtarget_));
%                 end
%             end
                    
            if strcmpi(class(obj),'cBatman'), obj.checkflag_ = 0;end
        
            unwindtrade = obj.trade_;
            obj.status_ = 'closed';
            %
            if updatepnlforclosedtrade
                obj.trade_.status_ = 'closed';
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
    else
        if obj.trade_.opendirection_ == 1
            obj.trade_.runningpnl_ = obj.trade_.openvolume_*(tickBid-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
        else
            obj.trade_.runningpnl_ = -obj.trade_.openvolume_*(tickAsk-obj.trade_.openprice_)/ obj.trade_.instrument_.tick_size * obj.trade_.instrument_.tick_value;
        end
    end
    
    %2.check with time stop if it is necessary
    if ~isempty(obj.trade_.stopdatetime1_) && obj.trade_.stopdatetime1_ < tickTime
        ismarketopen = istrading(tickTime,instrument.trading_hours,'tradingbreak',instrument.trading_break);
        if ismarketopen
            if strcmpi(class(obj),'cBatman'), obj.checkflag_ = 0;end
            
            obj.closestr_ = 'time breaches stop time';
            unwindtrade = obj.trade_;
            obj.status_ = 'closed';

            if doprint
                fprintf('%s:%s:%s of %s...\n',...
                    datestr(tickTime,'yyyy-mm-dd HH:MM:SS'),...
                    class(oj),...
                    obj.closestr_,...
                    obj.trade_.stopdatetime2_);
            end
            %
            if updatepnlforclosedtrade
                obj.trade_.status_ = 'closed';
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
    
end