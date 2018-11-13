function [ret] = setredline(obj,val)
%cStrat
    if ~isnumeric(val)
        error('%s:setredline:invalid input...',class(obj))
    end
    obj.redline_ = val;
    ret = 1;
end