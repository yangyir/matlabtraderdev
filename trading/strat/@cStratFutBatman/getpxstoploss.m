function val = getpxstoploss(obj,instrument)
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        val = obj.pxstoploss_(idx);
    else
        error('cStratFutBatman:getpxstoploss:instrument not found!')
    end
end