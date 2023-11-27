function [flag] = istime2print(mdefx,t)
%cmdefx
    mm = minute(t);
    
    MM_INTERVAL2PRINT = 10;
    if mod(mm,MM_INTERVAL2PRINT) == 0
        if ~mdefx.printed_
            flag = 1;
            mdefx.printed_ = 1;
        else
            flag = 0;
        end
    else
        if mdefx.printed_
            mdefx.printed_ = 0;
        end
        flag = 0;
    end
end

