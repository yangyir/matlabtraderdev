function [] = registerinstrument(obj,instrument)
    if ~isa(instrument,'cInstrument'),error('cMDEOpt:registerinstrument:invalid instrument input');end
    codestr = instrument.code_ctp;
    [isopt,~,~,underlierstr] = isoptchar(codestr);
    if ~isopt, return; end

    obj.qms_.registerinstrument(instrument);
    if isempty(obj.options_)
        obj.options_ = cInstrumentArray;
    end
    obj.options_.addinstrument(instrument);

    if isempty(obj.underliers_)
        obj.underliers_ = cInstrumentArray;
    end

    underlier = cFutures(underlierstr);
    underlier.loadinfo([underlierstr,'_info.txt']);
    obj.underliers_.addinstrument(underlier);

end
%end of registerinstrument