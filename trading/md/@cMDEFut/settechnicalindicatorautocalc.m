function [] = settechnicalindicatorautocalc(mdefut,instrument,calcflag)
    if ischar(instrument)
        instrument = code2instrument(instrument);
    end

    if ~isa(instrument,'cInstrument')
        error('cMDEFut:settechnicalindicatorautocalc:invalid instrument input')
    end

    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    flag = false;
    for i = 1:ns
        if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
            flag = true;
            mdefut.technical_indicator_autocalc_(i) = calcflag;
            break
        end
    end
    if ~flag
        error('cMDEFut:settechnicalindicatorautocalc:instrument not found')
    end
end
%end of settechnicalindicatorautocalc