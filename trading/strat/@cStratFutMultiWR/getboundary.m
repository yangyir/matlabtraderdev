function [overbought,oversold] = getboundary(stratfutwr,instrument)
    [flag,idx] = stratfutwr.instruments_.hasinstrument(instrument);
    if flag
        overbought = stratfutwr.overbought_(idx);
        oversold = stratfutwr.oversold_(idx);
    else
        error('cStratFutMultiWR:getboundary:instrument not found')
    end
end