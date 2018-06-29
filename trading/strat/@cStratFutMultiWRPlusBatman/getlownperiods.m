function [lowp,lowt] = getlownperiods(obj,instrument)
    if ~(isa(instrument,'cInstrument') || ischar(instrument)) 
        error('cStratFutMultiWRPlusBatman:getlownperiods:invalid instrument input')
    end
    
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        nperiods = obj.nperiods_(idx);
    else
        error('cStratFutMultiWRPlusBatman:getlownperiods:instrument not found')
    end


    histcandles = obj.mde_fut_.gethistcandles(instrument);
    candlesticks = obj.mde_fut_.getcandles(instrument);

    timevec = [histcandles(:,1);candlesticks(:,1)];
    if size(timevec,1) < nperiods
        error('cStratFutMultiWRPlusBatman:gethighperiods:insufficient historical data')
    end

    lowpx = [histcandles(:,4);candlesticks(:,4)];
    lowp = min(lowpx(end-nperiods+1:end));
    idx = lowpx == lowp;
    lowt = timevec(idx);
    
end