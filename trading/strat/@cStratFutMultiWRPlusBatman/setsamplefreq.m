function [] = setsamplefreq(obj,instrument,freq)
    if isempty(obj.samplefreq_), obj.samplefreq_ = ones(obj.count,1);end

    [flag,idx] = obj.instruments_.hasinstrument(instrument);

    if flag
        obj.samplefreq_(idx) = freq;
    else
        error('cStratFutMultiWRPlusBatman:settradingfreq:instrument not found')
    end

    if ischar(instrument)
        instrument = code2instrument(instrument);
    end
    obj.mde_fut_.setcandlefreq(freq,instrument);

end
%end of settradingfreq