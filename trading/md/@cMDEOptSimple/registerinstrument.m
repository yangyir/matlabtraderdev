function [] = registerinstrument(obj,instrument)
%cMDEOptSimple
    if ~isa(instrument,'cInstrument')
        instrument = code2instrument(instrument);
    end
        
    codestr = instrument.code_ctp;
    [isopt,~,~,underlierstr] = isoptchar(codestr);
    if ~isopt, return; end

    obj.qms_.registerinstrument(instrument);
    
    if isempty(obj.options_),obj.options_ = cInstrumentArray;end
    
    if ~obj.options_.hasinstrument(instrument), obj.options_.addinstrument(instrument);end
    
    if isempty(obj.underliers_), obj.underliers_ = cInstrumentArray;end

    underlier = cFutures(underlierstr);
    underlier.loadinfo([underlierstr,'_info.txt']);
    
    
    if ~obj.underliers_.hasinstrument(underlier), obj.underliers_.addinstrument(underlier);end
end
%end of registerinstrument