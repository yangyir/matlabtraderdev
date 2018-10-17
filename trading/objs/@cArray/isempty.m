function [ret] = isempty(obj)
    try
        if obj.latest_ == 0
            ret = true;
        else                
            ret = false;
        end
    catch
        ret = true;
    end
end