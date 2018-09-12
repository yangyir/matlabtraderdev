function vout = getbandwidthmax(obj,instrument)
    [flag,idx] = obj.hasinstrument(instrument);
    if flag
        vout = obj.bandwidthmax_(idx);
    else
        error('cStratFutMultiWRPlusBatman:getbandwidthmax:instrument not found')
    end
end