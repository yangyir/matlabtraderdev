function histcandles = gethistcandles(mdeopt,instrument)
% a cMDEOpt function
    histcandles = {};
    if isempty(mdeopt.hist_candles_), return; end

    instruments = mdeopt.qms_.instruments_.getinstrument;
    ns = size(instruments,1);
    
    if nargin < 2
        histcandles = mdeopt.hist_candles_;
        return
    end
    
    if ischar(instrument), instrument = code2instrument(instrument); end
    
    if ~isa(instrument,'cInstrument'), error('%s:gethistcandles:invalid instrument input',class(mdeopt)); end

    flag = false;
    for i = 1:ns
        if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
            flag = true;
            histcandles = cell(1,1);
            histcandles{1} = mdeopt.hist_candles_{i};
            break
        end
    end

    if ~flag, error('%s:gethistcandles:instrument not found',class(mdeopt));end
end
%end of gethistcandles