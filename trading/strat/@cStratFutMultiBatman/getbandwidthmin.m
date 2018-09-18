function vout = getbandwidthmin(obj,instrument)
    [flag,idx] = obj.hasinstrument(instrument);
    if flag
        vout = obj.bandwidthmin_(idx);
    else
        error('cStratFutMultiBatman:getbandwidthmin:instrument not found')
    end
end