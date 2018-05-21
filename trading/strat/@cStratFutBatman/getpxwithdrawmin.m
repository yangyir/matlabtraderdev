function val = getpxwithdrawmin(obj,instrument)
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        val = obj.pxwithdrawmin_(idx);
    else
        error('cStratFutBatman:getpxwithdrawmin:instrument not found!')
    end
end