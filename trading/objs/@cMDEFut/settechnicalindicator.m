function [] = settechnicalindicator(mdefut,instrument,indicators)
    if ~isa(instrument,'cInstrument')
        error('cMDEFut:settechnicalindicator:invalid instrument input')
    end

    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    flag = false;
    for i = 1:ns
        if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
            flag = true;
            if iscell(indicators)
                mdefut.technical_indicator_table_{i} = indicators;
            else
                mdefut.technical_indicator_table_{i} = {indicators};
            end
            break
        end
    end
    if ~flag
        error('cMDEFut:settechnicalindicator:instrument not found')
    end

end
%end of settechnicalindicator