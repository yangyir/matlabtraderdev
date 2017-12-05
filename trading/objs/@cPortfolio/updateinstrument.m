function [] = updateinstrument(obj,instrument,px,volume)
    [bool,idx] = obj.hasinstrument(instrument);
    if ~bool
        obj.addinstrument(instrument,px,volume);
    else
        obj.instrument_avgcost(idx,1) = px;
        obj.instrument_volume(idx,1) = volume;
    end
end