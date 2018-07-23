function [] = riskmanagement_batman(tradeOpen,candleStick,freq)    
    %riskmanagement is not required in case the trade is closed 
    if strcmpi(tradeOpen.status_,'closed'), return; end
    
    if strcmpi(tradeOpen.status_,'unset')
        instrument = tradeOpen.instrument_;
        tickSize = instrument.tick_size;
        tradeOpen.riskmanagementmethod_ = 'batman';
        if ~isempty(tradeOpen.extrainfo_)
            if strcmpi(tradeOpen.extrainfo_.signal,'wr')
                pxlowest = tradeOpen.extrainfo_.priceminumum;
                pxhighest = tradeOpen.extrainfo_.pricemaximum;
                pxstoploss = tradeOpen.openprice_-...
                    tradeOpen.opendirection_*(pxhighest-pxlowest)*tradeOpen.batman_.bandstoploss_;
                pxtarget = tradeOpen.openprice_+...
                    tradeOpen.opendirection_*(pxhighest-pxlowest)*tradeOpen.batman_.bandtarget_;
                tradeOpen.stoplossprice_ = round(pxstoploss/tickSize)*tickSize;
                tradeOpen.targetprice_ = round(pxtarget/tickSize)*tickSize;
            else
                error('riskmanagement_batman:signal %s not impmeneted',tradeOpen.extrainfo_.signal)
            end
            tradeOpen.batman_.pxtarget_ = pxtarget;
            tradeOpen.batman_.pxstoploss_ = pxstoploss;
        end
        
        tradeOpen.batman_.pxopen_ = tradeOpen.openprice_;
        tradeOpen.batman_.checkflag_ = 0;
        tradeOpen.batman_.pxsupportmin_ = -1;
        tradeOpen.batman_.pxsupportmax_ = -1;
        
        buckets = getintradaybuckets2('date',floor(tradeOpen.opendatetime1_),...
            'frequency',freq,...
            'tradinghours',instrument.trading_hours,...
            'tradingbreak',instrument.trading_break);
        idxTradeOpen = buckets(1:end-1) < tradeOpen.opendatetime1_ & buckets(2:end) >= tradeOpen.opendatetime1_; 
        bucketOpen = buckets(idxTradeOpen);
        if isempty(bucketOpen), error('internal error'); end
        
        if candleStick(1) > bucketOpen, tradeOpen.status_ = 'set'; end
        
        return
    end
    
    if strcmpi(tradeOpen.status_,'set')
        if strcmpi(tradeOpen.batman_.status_,'closed'),return;end
        %note:if the trade is set but not closed yet, as per backtest, we
        %check whether 1)the tick price breaches the stoploss and 2) the
        %last candles close breaches the relavant levels
        instrument = tradeOpen.instrument_;
        tickSize = instrument.tick_size;
        tickValue = instrument.tick_value;
        direction = tradeOpen.opendirection_;
        
        t = candleStick(1);
        kOpen = candleStick(2);
        kHigh = candleStick(3);
        kLow = candleStick(4);
        kClose = candleStick(5);
        
        %stop the trade once the stoptime is breached
        if ~isempty(tradeOpen.stoptime1_) && t >= tradeOpen.stoptime1_
            tradeOpen.status_ = 'closed';
            tradeOpen.batman_.status_ = 'closed';
            tradeOpen.closeprice_ = kClose;
            tradeOpen.closetime1_ = t;
            tradeOpen.closetime2_ = datestr(t,'yyyy-mm-dd');
            tradeOpen.closepnl_ = direction*(kClose-tradeOpen.openprice_)/tickSize*tickValue*tradeOpen.openvolume_;
            tradeOpen.runningpnl_ = 0;
            return
        end
        
        %stop the trade immediately if and only if the stoploss is breached
        %at any time
        if ( direction == 1 && kLow <= tradeOpen.stoplossprice_ ) || ...
               ( direction == -1 && kHigh >= tradeOpen.stoplossprice_ )
            tradeOpen.status_ = 'closed';
            tradeOpen.batman_.status_ = 'closed';
            tradeOpen.closeprice_ = tradeOpen.stoplossprice_;
            tradeOpen.closetime1_ = t;
            tradeOpen.closetime2_ = datestr(t,'yyyy-mm-dd');
            tradeOpen.closepnl_ = direction*(tradeOpen.closeprice_-tradeOpen.openprice_)/tickSize*tickValue*tradeOpen.openvolume_;
            tradeOpen.runningpnl_ = 0;
            return
        end
        
        if tradeOpen.batman_.pxsupportmin_ == -1 && tradeOpen.batman_.pxsupportmax_ == -1
            if direction == 1
                if kHigh >= tradeOpen.targetprice_
                    tradeOpen.batman_.pxresistence_ = 
                end
            elseif direction == -1
            end
        end
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
end