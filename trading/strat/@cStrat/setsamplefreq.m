function [] = setsamplefreq(obj,instrument,freq)
%cStrat    
    if ~isnumeric(freq), error('cStrat:setsamplefreq:invalid freq input');end

    [flag,idx] = obj.hasinstrument(instrument);
    if ~flag
        if isempty(obj.samplefreq_)
            obj.samplefreq_ = freq*ones(obj.count,1);
        else
            if size(obj.samplefreq_,1) < obj.count
                obj.samplefreq_ = [obj.samplefreq_;freq];
            end
        end
    else
        obj.samplefreq_(idx) = freq;
    end
    
    if ischar(instrument)
        instrument = code2instrument(instrument);
    end
    obj.mde_fut_.setcandlefreq(freq,instrument);

end
%end of settradingfreq