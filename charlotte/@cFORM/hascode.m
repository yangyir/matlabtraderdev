function [flag,idx] = hascode(obj,code)
    flag = false;
    idx = [];
    if ~ischar(code)
        return
    end
    
    n = size(obj.codes_,1);
    
    for i = 1:n
        if strcmpi(obj.codes_{i},code)
            flag = true;
            idx = i;
            break;
        end
    end
end