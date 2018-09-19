function [] = riskmanagement_futmultibatman(obj,dtnum)
%cStratFutMultiBatman
    ismarketopen = zeros(obj.count,1);
    instruments = obj.getinstruments;
    for i = 1:obj.count
        %firstly to check whether this is in trading hours
        ismarketopen(i) = istrading(dtnum,instruments{i}.trading_hours,...
            'tradingbreak',instruments{i}.trading_break);
    end
    
    if sum(ismarketopen) == 0, return; end
    
    ntrades = obj.helper_.trades_.latest_;
    %set risk manager
    for i = 1:ntrades
        trade_i = obj.helper_.trades_.node_(i);
        if strcmpi(trade_i.status_,'closed'), continue; end
        if ~isempty(trade_i.riskmanager_), continue;end
        %
        instrument = trade_i.instrument_;
        bandwidthmin = obj.getbandwidthmin(instrument);
        bandwidthmax = obj.getbandwidthmax(instrument);
        
        extrainfo = struct('bandstoploss',NaN,...
            'bandtarget',NaN,...
            'bandwidthmin',bandwidthmin,...
            'bandwidthmax',bandwidthmax);
        trade_i.setriskmanager('name','batman','extrainfo',extrainfo); 
    end
    
    %set status of trade
    for i = 1:ntrades
        trade_i = obj.helper_.trades_.node_(i);
        trade2unwind = trade_i.riskmanager_.riskmanagement('MDEFut',obj.mde_fut_,...
            'UpdatePnLForClosedTrade',false);
        if ~isempty(trade2unwind)
            obj.unwindtrade(trade2unwind);
        end
    end
    
end