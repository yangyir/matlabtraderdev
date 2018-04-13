function [ret] = isemptybook(obj)
    if isempty(obj.positions_)
        ret = true;
        return
    end
    
    if size(obj.positions_,1) == 0
        ret = true;
        return
    end
    
    ret = false;
end