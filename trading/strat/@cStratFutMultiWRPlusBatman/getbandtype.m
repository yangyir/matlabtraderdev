function vout = getbandtype(obj,instrument)
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        vout = obj.bandtype_(idx);
    else
        error('cStratFutMultiWRPlusBatman:getbandtype:instrument not found')
    end
end