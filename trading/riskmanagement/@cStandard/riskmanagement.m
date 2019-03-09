function [unwindtrade] = riskmanagement(obj,varargin)
%cStandard
    unwindtrade = {};
    if strcmpi(obj.status_,'closed'), return; end

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('MDEFut',{},@(x) validateattributes(x,{'cMDEFut'},{},'','MDEFut'));
    p.addParameter('Debug',false,@islogical);
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.parse(varargin{:});
    mdefut = p.Results.MDEFut;
    debug = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    
    if isempty(mdefut)
        unwindtrade = [];
        return
    end
    
    trade = obj.trade_;
    if strcmpi(trade.status_,'closed') 
        unwindtrade = [];
        return
    end
     
    instrument = trade.instrument_;
    candleCell = mdefut.getcandles(instrument);
    if isempty(candleCell)
        fprintf('WARNING:cStandard:riskmanagement:empty candle returned!!!');
        unwindtrade = [];
        return
    end
    candleK = candleCell{1};
    
    if strcmpi(trade.status_,'unset')
        %set the trade when the candle moves to the next candle after the
        %trade open
        openBucket = gettradeopenbucket(trade,trade.opensignal_.frequency_);
        candleTime = candleK(end,1);
        if openBucket <= candleTime
            trade.status_ = 'set';
            obj.status_ = 'set';
            if isnan(obj.pxstoploss_) && isnan(obj.pxtarget_)
                %note:in case pxstoploss_ is not set here,
                %we use the low/high as of the open candle for
                %stoploss for long/short position respectively
                candleHigh = candleK(end,3);
                candleLow = candleK(end,4);
                if trade.opendirection_ == 1
                    obj.pxstoploss_ = candleLow;
                else
                    obj.pxstoploss_ = candleHigh;
                end
            end
        end
    end
    
    if ~strcmpi(trade.status_,'set'), return; end
    
    if obj.pxstoploss_ == -9.99 && obj.pxtarget_ == -9.99, return; end
    if trade.opendirection_ == 1 && obj.pxstoploss_ == -Inf && obj.pxtarget_ == Inf, return;end
    if trade.opendirection_ == -1 && obj.pxstoploss_ == Inf && obj.pxtarget_ == -Inf, return;end
    
    lasttick = mdefut.getlasttick(instrument);
    if isempty(lasttick), return; end
    
    ticktime = lasttick(1);
    tickbid = lasttick(2);
    tickask = lasttick(3);
    ticktrade = lasttick(4);
    
    %we always use tick price to determine whether the stoploss is breached
    
    isstoplossbreached = obj.pxstoploss_ ~= -9.99 && ((trade.opendirection_ == 1 && ticktrade < obj.pxstoploss_) || ...
                (trade.opendirection_ == -1 && ticktrade > obj.pxstoploss_));
    
    istargetbreached = obj.pxtarget_ ~= -9.99 && ((trade.opendirection_ == 1 && ticktrade > obj.pxtarget_) || ...
                (trade.opendirection_ == -1 && ticktrade < obj.pxtarget_));        
    
    if isstoplossbreached   || istargetbreached
        obj.status_ = 'closed';
        trade.status_ = 'closed';
        unwindtrade = trade;
        if debug
            fprintf('%s:batman closed as tick price breaches stoploss price at %s...\n',...
                datestr(ticktime,'yyyy-mm-dd HH:MM'),...
                num2str(obj.pxstoploss_));
        end
        
        if updatepnlforclosedtrade
            trade.runningpnl_ = 0;
            if trade.opendirection_ == 1
                trade.closepnl_ = trade.openvolume_*(tickbid-trade.openprice_)/ instrument.tick_size * instrument.tick_value;
                trade.closeprice_ = tickbid;
            elseif trade.opendirection_ == -1
                trade.closepnl_ = -trade.openvolume_*(tickask-trade.openprice_)/ instrument.tick_size * instrument.tick_value;
                trade.closeprice_ = tickask;
            end
            trade.closedatetime1_ = ticktime;
        end
        
        return
    else
        if trade.opendirection_ == 1
            trade.runningpnl_ = trade.openvolume_*(tickbid-trade.openprice_)/ instrument.tick_size * instrument.tick_value;
        else
            trade.runningpnl_ = -trade.openvolume_*(tickask-trade.openprice_)/ instrument.tick_size * instrument.tick_value;
        end
    end
     
end