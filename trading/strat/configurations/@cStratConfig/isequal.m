function [ret] = isequal(obj,anotherconfig)
%cStratConfig
    class1 = class(obj);
    class2 = class(anotherconfig);
    
    if ~strcmpi(class1,class2)
        ret = false;
        return
    end
    
    p = properties(obj);
    ret = true;
    for i = 1:length(p)
        if strcmpi(p{i},'instrument_'), continue; end
        v1 = obj.(p{i});
        v2 = anotherconfig.(p{i});
        if isnumeric(v1)
            if v1 ~= v2
                ret = false;
                break
            end 
        elseif ischar(v1)
            if ~strcmpi(v1,v2)
                ret = false;
                break
            end
        end
    end
    
end