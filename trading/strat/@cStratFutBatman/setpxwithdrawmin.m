function [] = setpxwithdrawmin(obj,instrument,val)
    if isempty(obj.pxwithdrawmin_), obj.pxwithdrawmin_ = -1*ones(obj.count,1); end
    
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    
    if flag
        obj.pxwithdrawmin_(idx) = val;
    else
        error('cStratFutBatman:setpxwithdrawmin:instrument not found!')
    end
    
end