function freq_ = getcandlefreq(mdeopt,instrument)
% a cMDEOpt function
    if nargin < 2
        freq_ = mdeopt.candle_freq_;
        return
    end
    
    if ischar(instrument), instrument = code2instrument(instrument); end

    if ~isa(instrument,'cInstrument'), error('%s:getcandlefreq:invalid instrument input',class(mdeopt)); end

    instruments = mdeopt.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    flag = false;
    for i = 1:ns
        if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
            flag = true;
            freq_ = mdeopt.candle_freq_(i);
            break
        end
    end

    if ~flag, error('%s:getcandlefreq:instrument not found',class(mdeopt)); end
end