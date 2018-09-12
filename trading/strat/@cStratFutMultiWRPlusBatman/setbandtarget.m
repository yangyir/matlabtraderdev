function [] = setbandtarget(obj,instrument,vin)
    if isempty(obj.bandtarget_), obj.bandtarget_ = 0.01*ones(obj.count,1);end

    [flag,idx] = obj.hasinstrument(instrument);
    if flag
        obj.bandtarget_(idx) = vin;
    else
        error('cStratFutMultiWRPlusBatman:setbandtarget:instrument not found')
    end
end