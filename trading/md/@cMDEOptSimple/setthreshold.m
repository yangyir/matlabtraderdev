function [] = setthreshold(obj,underlier,val)
%cMDEOptSimple
    if ~isa(underlier,'cInstrument'), underlier = code2instrument(underlier);end
    [flag,idx] = obj.underliers_.hasinstrument(underlier);
    
    if ~flag
        if isempty(obj.threshold_)
            obj.threshold_ = val;
            return
        end
        obj.threshold_ = [obj.threshold_;val];
    else
        obj.threshold_(idx) = val;
    end
end