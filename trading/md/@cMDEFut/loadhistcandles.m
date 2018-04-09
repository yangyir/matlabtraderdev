function [] = loadhistcandles(mdefut,instrument,histcandles)
    if ~isa(instrument,'cInstrument'), error('cMDEFut:loadhistcandles:invalid instrument input'); end

    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    if isempty(mdefut.hist_candles_), mdefut.hist_candles_ = cell(ns,1); end

    flag = false;
    for i = 1:ns
        if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
            flag = true;
            mdefut.hist_candles_{i} = histcandles;
            break
        end
    end
    if ~flag, error('cMDEFut:loadhistcandles:instrument not found'); end
end