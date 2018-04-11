function [bool,idx] = hasinstrument(obj,instrument)
    if ~obj.isvalid
        bool = false;
        idx = 0;
        return
    end

    if ischar(instrument)
        code_str = instrument;
    elseif isa(instrument,'cInstrument')
        code_str = instrument.code_ctp;
    else
        error('cInstrumentArray:hasinstrument:cInstrument or char type of input expected')
    end
    n = obj.count;
    bool = false;
    idx = 0;
    for i = 1:n
        if strcmpi(code_str,obj.list_{i}.code_ctp)
            bool = true;
            idx = i;
            break;
        end
    end

end
%end of hasinstrument