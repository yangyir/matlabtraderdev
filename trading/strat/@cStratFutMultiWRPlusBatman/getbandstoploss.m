function vout = getbandstoploss(obj,instrument)
    [flag,idx] = obj.hasinstrument(instrument);
    if flag
        vout = obj.bandstoploss_(idx);
    else
        error('cStratFutMultiWRPlusBatman:getbandstoploss:instrument not found')
    end
end