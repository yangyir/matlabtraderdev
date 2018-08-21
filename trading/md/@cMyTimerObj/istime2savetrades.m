function [flag] = istime2savetrades(obj,t)
%note:yangyiran 20180821
%the trade is saved between 15:15pm and 15:25pm on each trading date
    
    if obj.istime2sleep(t)
        flag = false;
        return
    end

    if ischar(t)
        tnum = datenum(t);
    else
        tnum = t;
    end
    hh = hour(tnum);
    mm = minute(tnum) + hh*60;
    
    if mm > obj.mm_15_15_ && mm <= obj.mm_15_25_
        flag = true;
    else
        flag = false;
    end
end