function [unwindtrade] = riskmanagementwithcandle(obj,candlek,varargin)
%method of cStairs(cTradeRiskManager)

    unwindtrade = {};
    if strcmpi(obj.status_,'closed'), return; end
    if strcmpi(obj.trade_.status_,'closed'), return; end
    if obj.pxstoploss_ == -9.99, return;end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('UseCandleLastOnly',false,@islogical);
    p.addParameter('Debug',false,@islogical)
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.addParameter('UseOpenCandle',true,@islogical);%not used here
    p.parse(varargin{:});
    usecandlelastonly = p.Results.UseCandleLastOnly;
    doprint = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    
    candleTime = candlek(1);
    candleOpen = candlek(2);
    candleHigh = candlek(3);
    candleLow = candlek(4);
    candleLast = candlek(5);
    
    trade = obj.trade_;
    direction = trade.opendirection_;
    volume = trade.openvolume_;
    instrument = trade.instrument_;
    
    if strcmpi(trade.status_,'unset')
        openbucket = gettradeopenbucket(trade,trade.opensignal_.frequency_);
        % return in case the candle happened in the past
        if openbucket > candleTime, return; end
        %
        % set the trade once the openbucket is finished
        if openbucket == candleTime
            if isempty(obj.dynamicstoploss_)
                obj.dynamicstoploss_ = obj.pxstoploss_;
            end
            
            trade.status_= 'set';
            obj.status_ = 'set';
            
        elseif openbucket < candleTime
            %note:this shall never happen
            error('cStairs:riskmanagementwithcandle:internal error!!!')
        end
    end
    
    %1.check with time stop if it is necessary
    if ~isempty(trade.stopdatetime1_) && trade.stopdatetime1_ < candleTime
        obj.status_ = 'closed';
        unwindtrade = trade;
        if doprint
            fprintf('%s:stairs closed as time breaches stop time at %s...\n',...
                datestr(candleTime,'yyyy-mm-dd HH:MM'),...
                trade.stopdatetime2_);
        end
        if updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            obj.trade_.closepnl_ = direction*volume*(candleOpen-obj.trade_.openprice_)/ instrument.tick_size * instrument.tick_value;
            obj.trade_.closedatetime1_ = obj.trade_.stopdatetime1_ + 1/86400;
            obj.trade_.closeprice_ = candleOpen;
        end
        return
    end
    %
    %
    if strcmpi(trade.status_,'unset') 
        error('cStairs:riskmanagementwithcandle:internal error');
    end
    
    if ~usecandlelastonly
        if (candleLow < obj.pxstoploss_ && direction == 1) || ...
                (candleHigh > obj.pxstoploss_ && direction == -1)
            closeflag = 1;
        else
            closeflag = 0;
        end
        if closeflag
            obj.status_ = 'closed';
            unwindtrade = obj.trade_;
            if direction == 1 && candleOpen < obj.pxstoploss_
                closeprice = candleOpen;
            elseif direction == -1 && candleOpen > obj.pxstoploss_
                closeprice = candleOpen;
            else
                closeprice = obj.pxstoploss_;
            end
            closetime = candleTime;
            %
            if doprint
                fprintf('%s:stairs closed as tick price breaches stoploss price at %s...\n',...
                    datestr(closetime,'yyyy-mm-dd HH:MM'),...
                    num2str(closeprice));
            end
            %
            if updatepnlforclosedtrade
                obj.trade_.runningpnl_ = 0;
                obj.trade_.closepnl_ = direction*volume*(closeprice-trade.openprice_)/instrument.tick_size * instrument.tick_value;
                obj.trade_.closedatetime1_ = closetime;
                obj.trade_.closeprice_ = closeprice;
            end
            %
            return
        end
    end
    
    if direction == 1 && candleLast < obj.pxstoploss_
        closeflag = 1;
        if doprint, fprintf('close candle time:%s\n',datestr(candleTime,'yyyy-mm-dd HH:MM'));end
    elseif direction == -1 && candleLast > obj.pxstoploss_
        closeflag = 1;
        if doprint, fprintf('close candle time:%s\n',datestr(candleTime,'yyyy-mm-dd HH:MM'));end
    else
        closeflag = 0;
        pnl = direction*volume*(candleLast-trade.openprice_)/ instrument.tick_size * instrument.tick_value;
        if pnl > obj.maxpnl_
            obj.maxpnl_ = pnl;
            adj = (candleLast-trade.openprice_)*obj.reserveratio_;
            if direction == 1
                adj = floor(adj/instrument.tick_size)*instrument.tick_size;
            else
                adj = ceil(adj/instrument.tick_size)*instrument.tick_size;
            end
            
            obj.dynamicstoploss_ = trade.openprice_+adj;
            obj.pxstoploss_ = obj.dynamicstoploss_;
        end
    end
    
    if closeflag
        obj.status_ = 'closed';
        obj.trade_.status_ = 'closed';
        unwindtrade = obj.trade_;
        if updatepnlforclosedtrade
            obj.trade_.runningpnl_ = 0;
            closeprice = candleLast;
            obj.trade_.closepnl_ = direction*volume*(closeprice-trade.openprice_)/instrument.tick_size * instrument.tick_value;
            obj.trade_.closedatetime1_ = candleTime;
            obj.trade_.closeprice_ = closeprice;
        end
        return
    else
        obj.trade_.runningpnl_ = direction*volume*(candleLast-trade.openprice_)/instrument.tick_size * instrument.tick_value;
   end    
        
    
    
end