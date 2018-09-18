function vout = getbandwidthmax(obj,instrument)
    [flag,idx] = obj.hasinstrument(instrument);
    if flag
        vout = obj.bandwidthmax_(idx);
    else
        error('cStratFutMultiBatman:getbandwidthmax:instrument not found')
    end
end