function val = getpxopen(obj,instrument)
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        val = obj.pxopen_(idx);
    else
        error('cStratFutBatman:getpxopen:instrument not found!')
    end
end