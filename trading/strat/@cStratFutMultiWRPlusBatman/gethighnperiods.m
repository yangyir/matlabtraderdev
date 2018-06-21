function [highp,hight] = gethighnperiods(obj,instrument)
    if ~(isa(instrument,'cInstrument') || ischar(instrument)) 
        error('cStratFutMultiWRPlusBatman:gethighnperiods:invalid instrument input')
    end
    
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        nperiods = obj.nperiods_(idx);
    else
        error('cStratFutMultiWRPlusBatman:gethighnperiods:instrument not found')
    end

    histcandles = obj.mde_fut_.gethistcandles(instrument);
    candlesticks = obj.mde_fut_.getcandles(instrument);
    
    timevec = [histcandles(:,1);candlesticks(:,1)];
    if size(timevec,1) < nperiods
        error('cStratFutMultiWRPlusBatman:gethighperiods:insufficient historical data')
    end
    
    highpx = [histcandles(:,3);candlesticks(:,3)];
    highp = max(highpx(end-nperiods+1:end));
    idx = highpx == highp;
    hight = timevec(idx);

end