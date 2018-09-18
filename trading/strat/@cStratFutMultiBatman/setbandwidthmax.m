function [] = setbandwidthmax(obj,instrument,vin)
    if isempty(obj.bandwidthmax_), obj.bandwidthmax_ = ones(obj.count,1)/2;end

    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    if flag
        obj.bandwidthmax_(idx) = vin;
    else
        error('cStratFutMultiBatman:setbandwidthmax:instrument not found')
    end
end