function n = getcandlecount(mdeopt,instrument)
% a cMDEOpt function
    if nargin < 2
        n = mdeopt.candles_count_;
        return
    end

    if ischar(instrument), instrument = code2instrument(instrument); end
    
    if ~isa(instrument,'cInstrument'), error('%s:getcandlecount:invalid instrument input',class(mdeopt)); end
    
    instruments = mdeopt.qms_.instruments_.getinstrument;
    ns = size(instruments,1);

    flag = false;
    n = 0;
    for i = 1:ns
        if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
            flag = true;
            n = mdeopt.candles_count_(i);
            break
        end
    end

    if ~flag, error('%s:getcandlecount:instrument not found',class(mdeopt)); end


end