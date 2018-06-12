function [overbought,oversold] = getboundary(obj,instrument)
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        overbought = obj.overbought_(idx);
        oversold = obj.oversold_(idx);
    else
        error('cStratFutMultiWRPlusBatman:getboundary:instrument not found')
    end
end