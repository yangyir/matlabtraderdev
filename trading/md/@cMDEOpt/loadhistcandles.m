function [] = loadhistcandles(mdeopt,instrument,histcandles)
% a cMDEOpt function
    if ~isa(instrument,'cInstrument'), error('%s:loadhistcandles:invalid instrument input',class(mdeopt)); end

    instruments = mdeopt.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    if isempty(mdeopt.hist_candles_), mdeopt.hist_candles_ = cell(ns,1); end

    flag = false;
    for i = 1:ns
        if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
            flag = true;
            mdeopt.hist_candles_{i} = histcandles;
            break
        end
    end
    if ~flag, error('%s:loadhistcandles:instrument not found',class(mdeopt)); end
end