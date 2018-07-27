function vout = getbandwidthmin(obj,instrument)
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        vout = obj.bandwidthmin_(idx);
    else
        error('cStratFutMultiWRPlusBatman:getbandwidthmin:instrument not found')
    end
end