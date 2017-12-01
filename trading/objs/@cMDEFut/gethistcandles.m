function histcandles = gethistcandles(mdefut,instrument)
    if ~isa(instrument,'cInstrument')
        error('cMDEFut:gethistcandles:invalid instrument input')
    end

    if isempty(mdefut.hist_candles_), return; end

    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    flag = false;
    for i = 1:ns
        if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
            flag = true;
            histcandles = mdefut.hist_candles_{i};
            break
        end
    end

    if ~flag, error('cMDEFut:gethistcandles:instrument not found');end
end
%end of gethistcandles