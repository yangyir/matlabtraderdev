function [] = setbandtype(obj,instrument,vin)
    if isempty(obj.bandtype_), obj.bandtype_ = zeros(obj.count,1);end

    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        obj.bandtype_(idx) = vin;
    else
        error('cStratFutMultiWRPlusBatman:setbandtype:instrument not found')
    end
end