function [] = settradingfreq(strategy,instrument,freq)
    if isempty(strategy.tradingfreq_), strategy.tradingfreq_ = ones(strategy.count,1);end

    [flag,idx] = strategy.instruments_.hasinstrument(instrument);

    if flag
        strategy.tradingfreq_(idx) = freq;
    else
        error('cStratFutMultiWR:settradingfreq:instrument not found')
    end

    strategy.mde_fut_.setcandlefreq(freq,instrument);

end
%end of settradingfreq