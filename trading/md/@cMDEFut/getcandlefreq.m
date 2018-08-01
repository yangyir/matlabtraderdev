function freq_ = getcandlefreq(mdefut,instrument)
    if nargin < 2
        freq_ = mdefut.candle_freq_;
        return
    end
    
    if ischar(instrument), instrument = code2instrument(instrument); end

    if ~isa(instrument,'cInstrument'), error('cMDEFut:getcandlefreq:invalid instrument input'); end

    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    flag = false;
    for i = 1:ns
        if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
            flag = true;
            freq_ = mdefut.candle_freq_(i);
            break
        end
    end

    if ~flag, error('cMDEFut:getcandlefreq:instrument not foung'); end
end