function [] = setboundary(strategy,instrument,overbought,oversold)
    if isempty(strategy.overbought_), strategy.overbought_ = zeros(strategy.count,1);end
    if isempty(strategy.oversold_), strategy.oversold_ = -100*ones(strategy.count,1);end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);
    if flag
        strategy.overbought_(idx) = overbought;
        strategy.oversold_(idx) = oversold;
    else
        error('cStratFutMultiWR:setboundary:instrument not found')
    end
end
%end of setboundary