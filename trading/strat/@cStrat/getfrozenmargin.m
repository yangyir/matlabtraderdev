function val = getfrozenmargin(obj)
%cStrat
%return frozen margin of any pending entrust
    try
        npending = obj.helper_.entrustspending_.latest;
    catch
        npending = 0;
    end
    
    val = 0;
    for i = 1:npending
        e = obj.helper_.entrustspending_.node(i);
        if e.offsetFlag == 1
            price = e.price;
            volume = e.volume;
            instrument = code2instrument(e.instrumentCode);
            marginrate = instrument.init_margin_rate;
            ticksize = instrument.tick_size;
            tickvalue = instrument.tick_value;
            val = val + price*volume*marginrate/ticksize*tickvalue;
        else
            val = val + 0;
        end
    end
end