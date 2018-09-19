function freq = getsamplefreq(obj,instrument)

    [flag,idx] = obj.instruments_.hasinstrument(instrument);

    if flag
        freq = obj.samplefreq_(idx);
    else
        error('cStratFutMultiWRPlusBatman:getsamplefreq:instrument not found')
    end
 
end