function freq = getsamplefreq(obj,instrument)
%cStrat
    [flag,idx] = obj.instruments_.hasinstrument(instrument);

    if flag
        freq = obj.samplefreq_(idx);
    else
        error('cStrat:getsamplefreq:instrument not found')
    end
 
end