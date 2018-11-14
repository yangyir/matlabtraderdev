function [ret] = setamberline(obj,val)
%cStrat
    if ~isnumeric(val)
        error('%s:setamberline:invalid input...',class(obj))
    end
    obj.amberline_ = val;
    ret = 1;
    
end