function freq = gettradingfreq(stratfutwr,instrument)

    [flag,idx] = stratfutwr.instruments_.hasinstrument(instrument);

    if flag
        freq = stratfutwr.tradingfreq_(idx);
    else
        error('cStratFutMultiWR:gettradingfreq:instrument not found')
    end
 
end