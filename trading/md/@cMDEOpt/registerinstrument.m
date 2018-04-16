function [] = registerinstrument(obj,instrument)
    if ~isa(instrument,'cInstrument'),error('cMDEOpt:registerinstrument:invalid instrument input');end
    codestr = instrument.code_ctp;
    [isopt,~,~,underlierstr] = isoptchar(codestr);
    if ~isopt, return; end

    obj.qms_.registerinstrument(instrument);
    if isempty(obj.options_)
        obj.options_ = cInstrumentArray;
    end
    
    if ~obj.options_.hasinstrument(instrument)
        obj.options_.addinstrument(instrument);
        obj.delta_ = [obj.delta_;0];
        obj.gamma_ = [obj.gamma_;0];
        obj.vega_ = [obj.vega_;0];
        obj.theta_ = [obj.theta_;0];
        obj.impvol_ = [obj.impvol_;0];
        %
        obj.deltacarry_ = [obj.deltacarry_;0];
        obj.gammacarry_ = [obj.gammacarry_;0];
        obj.vegacarry_ = [obj.vegacarry_;0];
        obj.thetacarry_ = [obj.thetacarry_;0];
        %
        pnlriskoutput = pnlriskbreakdown1(instrument,getlastbusinessdate);
        obj.deltacarryyesterday_ = [obj.deltacarryyesterday_;pnlriskoutput.deltacarry];
        obj.gammacarryyesterday_ = [obj.deltacarryyesterday_;pnlriskoutput.gammacarry];
        obj.vegacarryyesterday_ = [obj.vegacarryyesterday_;pnlriskoutput.vegacarry];
        obj.thetacarryyesterday_ = [obj.thetacarryyesterday_;pnlriskoutput.thetacarry];
        obj.impvolcarryyesterday_ = [obj.impvolcarryyesterday_;pnlriskoutput.iv2];
        obj.pvcarryyesterday_ = [obj.pvcarryyesterday_;pnlriskoutput.premium2];
    end
    
    

    if isempty(obj.underliers_)
        obj.underliers_ = cInstrumentArray;
    end

    underlier = cFutures(underlierstr);
    underlier.loadinfo([underlierstr,'_info.txt']);
    obj.underliers_.addinstrument(underlier);

end
%end of registerinstrument