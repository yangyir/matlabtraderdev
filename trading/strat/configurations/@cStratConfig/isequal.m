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
        if obj.(p{i}) ~= anotherconfig.(p{i})
            ret = false;
            break
        end
    end
    
end