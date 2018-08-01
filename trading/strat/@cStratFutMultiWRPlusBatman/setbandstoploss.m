function [] = setbandstoploss(obj,instrument,vin)
    if isempty(obj.bandstoploss_), obj.bandstoploss_ = 0.01*ones(obj.count,1);end

    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        obj.bandstoploss_(idx) = vin;
    else
        error('cStratFutMultiWRPlusBatman:bandstoploss:instrument not found')
    end
end