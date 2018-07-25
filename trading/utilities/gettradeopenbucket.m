function [openbucket1,openbucket2] = gettradeopenbucket(trade,freq)
    if ~isa(trade,'cTradeOpen')
        error('gettradeopenbucket:invalid trade input')
    end
    
    if hour(trade.opendatetime1_) < 9
        opendate = floor(trade.opendatetime1_) - 1;
    else
        opendate = floor(trade.opendatetime1_);
    end

    instrument = trade.instrument_;
    buckets = getintradaybuckets2('date',opendate,...
            'frequency',freq,...
            'tradinghours',instrument.trading_hours,...
            'tradingbreak',instrument.trading_break);
    idxTradeOpen = buckets(1:end-1) < trade.opendatetime1_ & buckets(2:end) >= trade.opendatetime1_; 
    openbucket1 = buckets(idxTradeOpen);
    openbucket2 = datestr(openbucket1,'yyyy-mm-dd HH:MM:SS');
    
end