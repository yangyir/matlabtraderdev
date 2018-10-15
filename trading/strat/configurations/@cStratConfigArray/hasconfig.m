function [ret] = hasconfig(obj,config)
    if ~isa(config,'cStratConfig')
        error([class(obj),':hasconfig:invalid config input']);
    end

    n = obj.latest_;
    if n == 0
        ret = false;
        return
    end
    
    ret = false;
    for i = 1:n
        if obj.node_(i).isequal(config)
            ret = true;
            break
        end
    end
    
end