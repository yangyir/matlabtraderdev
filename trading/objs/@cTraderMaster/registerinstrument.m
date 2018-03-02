function ret = registerinstrument(obj,instrument)
    if ~isa(instrument,'cInstrument')
        error('cTraderMaster:registerinstrument:invalid instrument input')
    end
    
    if isa(instrument,'cFutures')
        obj.mdefut_.registerinstrument(instrument);
    elseif isa(instrument,'cOption')
        obj.mdeopt_.registerinstrument(instrument);
    end
    
    if isempty(obj.instruments_)
        obj.instruments_ = cInstrumentArray;
    end
    
    obj.instruments_.addinstrument(instrument);
    
    ret = 1;
    
end