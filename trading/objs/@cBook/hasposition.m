function [bool,idx] = hasposition(obj,argin)
% cBook
    if isempty(obj.positions_)
        bool = false;
        idx = 0;
        return
    end
    
    if ischar(argin)
        code_ctp = argin;
    elseif isa(argin,'cInstrument')
        code_ctp = argin.code_ctp;
    else
        error('cBook:hasposition:invalid input')
    end
    
    bool = false;
    idx = 0;
    n = size(obj.positions_,1);
    for i = 1:n
        if strcmp(code_ctp,obj.positions_{i}.code_ctp_)
            bool = true;
            idx = i;
            break
        end
    end
end

