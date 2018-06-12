function [] = setboundary(obj,instrument,overbought,oversold)
    if isempty(obj.overbought_), obj.overbought_ = zeros(obj.count,1);end
    if isempty(obj.oversold_), obj.oversold_ = -100*ones(obj.count,1);end

    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        obj.overbought_(idx) = overbought;
        obj.oversold_(idx) = oversold;
    else
        error('cStratFutMultiWRPlusBatman:setboundary:instrument not found')
    end
end
%end of setboundary