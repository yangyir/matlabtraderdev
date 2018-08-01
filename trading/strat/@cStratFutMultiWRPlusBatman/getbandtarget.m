function vout = getbandtarget(obj,instrument)
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        vout = obj.bandtarget_(idx);
    else
        error('cStratFutMultiWRPlusBatman:getbandtarget:instrument not found')
    end
end