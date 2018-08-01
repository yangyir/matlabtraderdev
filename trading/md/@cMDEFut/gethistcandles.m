function histcandles = gethistcandles(mdefut,instrument)
    histcandles = {};
    if isempty(mdefut.hist_candles_), return; end

    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);
    
    if nargin < 2
        histcandles = mdefut.hist_candles_;
        return
    end
    
    if ischar(instrument), instrument = code2instrument(instrument); end
    
    if ~isa(instrument,'cInstrument'), error('cMDEFut:gethistcandles:invalid instrument input'); end

    flag = false;
    for i = 1:ns
        if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
            flag = true;
            histcandles = cell(1,1);
            histcandles{1} = mdefut.hist_candles_{i};
            break
        end
    end

    if ~flag, error('cMDEFut:gethistcandles:instrument not found');end
end
%end of gethistcandles