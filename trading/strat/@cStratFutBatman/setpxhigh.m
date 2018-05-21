function [] = setpxhigh(obj,instrument,val)
    if isempty(obj.pxhigh_), obj.pxhigh_ = -1*ones(obj.count,1); end
    
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    
    if flag
        obj.pxhigh_(idx) = val;
    else
        error('cStratFutBatman:setpxhigh:instrument not found!')
    end

end