function n = getcandlecount(mdefut,instrument)
    if nargin < 2
        n = mdefut.candles_count_;
        return
    end

    if ~isa(instrument,'cInstrument'), error('cMDEFut:getcandlecount:invalid instrument input'); end
    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    flag = false;
    n = 0;
    for i = 1:ns
        if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
            flag = true;
            n = mdefut.candles_count_(i);
            break
        end
    end

    if ~flag, error('cMDEFut:getcandlecount:instrument not found'); end


end