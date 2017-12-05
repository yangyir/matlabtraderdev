function [bool,idx] = hasinstrument(cPort,instrument)
    if ischar(instrument)
        code_ctp = instrument;
    elseif isa(instrument,'cInstrument')
        code_ctp = instrument.code_ctp;
    else
        error('cPortfolio:hasinstrument:cInstrument or char type of input expected')
    end
    
    n = cPort.count;
    bool = false;
    idx = 0;
    for i = 1:n
%         if strcmpi(code_ctp,cPort.instrument_list{i}.code_ctp)
        if strcmpi(code_ctp,cPort.pos_list_{i}.code_ctp_)
            bool = true;
            idx = i;
            break;
        end
    end

end
%end of hasinstrument