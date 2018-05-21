function val = getpxwithdrawmax(obj,instrument)
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        val = obj.pxwithdrawmax_(idx);
    else
        error('cStratFutBatman:getpxwithdrawmax:instrument not found!')
    end
end