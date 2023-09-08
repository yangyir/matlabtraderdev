function [flag] = istime2print(macrocn,t)
%cMacroCN
    mm = minute(t);
    
    MM_INTERVAL2PRINT = 5;
    if mod(mm,MM_INTERVAL2PRINT) == 0
        if ~macrocn.printed_
            flag = 1;
            macrocn.printed_ = 1;
        else
            flag = 0;
        end
    else
        if macrocn.printed_
            macrocn.printed_ = 0;
        end
        flag = 0;
    end
end

