function [ret] = isemptybook(obj)
    if isempty(obj.positions_)
        ret = true;
        return
    end
    
    if size(obj.positions_,1) == 0
        ret = true;
        return
    end
    
    holding = 0;
    for i = 1:size(obj.positions_,1)
        try
            holding = holding + obj.positions_{i}.position_total_;
        catch
            holding = holding + 0;
        end
    end
    if holding == 0
        ret = true;
        return
    end
    
    ret = false;
end