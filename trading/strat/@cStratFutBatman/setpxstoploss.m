function [] = setpxstoploss(obj,instrument,val)
    if isempty(obj.pxstoploss_), obj.pxstoploss_ = -1*ones(obj.count,1); end
    
    [flag,idx] = obj.instruments_.hasinstrument(instrument);
    
    if flag
        obj.pxstoploss_(idx) = val;
    else
        error('cStratFutBatman:setpxstoploss:instrument not found!')
    end
    

end