function [] = setbandwidthmin(obj,instrument,vin)
    if isempty(obj.bandwidthmin_), obj.bandwidthmin_ = ones(obj.count,1)/3;end

    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        obj.bandwidthmin_(idx) = vin;
    else
        error('cStratFutMultiWRPlusBatman:setbandwidthmin:instrument not found')
    end
    
end