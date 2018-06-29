function [ret] = isempty(obj)
    if obj.latest_ == 0
        ret = true;
    else                
        ret = false;
    end
end