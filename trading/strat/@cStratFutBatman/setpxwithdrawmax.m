function [] = setpxwithdrawmax(obj,instrument,val)
    if isempty(obj.pxwithdrawmax_), obj.pxwithdrawmax_ = -1*ones(obj.count,1); end
    
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    
    if flag
        obj.pxwithdrawmax_(idx) = val;
    else
        error('cStratFutBatman:setpxwithdrawmax:instrument not found!')
    end
    
end