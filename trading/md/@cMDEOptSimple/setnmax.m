function [] = setnmax(obj,underlier,val)
%cMDEOptSimple
    if ~isa(underlier,'cInstrument'), underlier = code2instrument(underlier);end
    [flag,idx] = obj.underliers_.hasinstrument(underlier);
    
    if ~flag
        if isempty(obj.nmaxtradeperday_)
            obj.nmaxtradeperday_ = val;
            return
        end
        obj.nmaxtradeperday_ = [obj.nmaxtradeperday_;val];
    else
        obj.nmaxtradeperday_(idx) = val;
    end
end