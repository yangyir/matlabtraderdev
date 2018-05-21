function val = getpxhigh(obj,instrument)
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        val = obj.pxhigh_(idx);
    else
        error('cStratFutBatman:gethigh:instrument not found!')
    end
end