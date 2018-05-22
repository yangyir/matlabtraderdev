function [] = setpxopen(obj,instrument,val)
    if isempty(obj.pxopen_), obj.pxopen_ = -1*ones(obj.count,1); end
    
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    
    if flag
        obj.pxopen_(idx) = val;
    else
        error('cStratFutBatman:setpxopen:instrument not found!')
    end
    
end