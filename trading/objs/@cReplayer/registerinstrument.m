function [] = registerinstrument(obj,instrument)
    if ischar(instrument)
        codestr = instrument;
    elseif isa(instrument,'cInstrument')
        codestr = instrument.code_ctp;
    else
        error('cReplayer:registerinstrument:invalid instrument input')
    end
    
    if isempty(obj.instruments_), obj.instruments_ = cInstrumentArray;end
    
    optflag = isoptchar(codestr);
    if isa(instrument,'cInstrument')
        obj.instruments_.addinstrument(instrument);
    elseif ischar(instrument)
        if optflag
            instrument = cOption(codestr);
            instrument.loadinfo([codestr,'_info.txt']);
            obj.instruments_.addinstrument(instrument);
        else
            instrument = cFutures(codestr);
            instrument.loadinfo([codestr,'_info.txt']);
            obj.instruments_.addinstrument(instrument);
        end
    end
    
    if isempty(obj.tickdata_)
        obj.tickdata_ = cell(obj.instruments_.count,1);
    else
        if size(obj.tickdata_,1) < obj.instruments_.count
            tickdata = cell(obj.instruments_.count,1);
            tickdata(1:size(obj.tickdata_,1)) = obj.tickdata_;
            tickdata{end} = zeros(10000,2);
            obj.tickdata_ = tickdata;
        end
    end
    
end