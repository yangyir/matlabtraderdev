function [] = setpxtarget(obj,instrument,val)
    if isempty(obj.pxtarget_), obj.pxtarget_ = -1*ones(obj.count,1); end
    
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    
    if flag
        obj.pxtarget_(idx) = val;
    else
        error('cStratFutBatman:setpxopen:instrument not found!')
    end
    

end