function val = getpxtarget(obj,instrument)
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        val = obj.pxtarget_(idx);
    else
        error('cStratFutBatman:getpxtarget:instrument not found')
    end
end