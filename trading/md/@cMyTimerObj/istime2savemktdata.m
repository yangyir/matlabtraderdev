function [flag] = istime2savemktdata(obj,t)
%note:yangyiran 20180821
%the mktdata is saved between 02:30am and 02:40am on each trading date
    
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
    
    if mm > obj.mm_02_30_ && mm <= obj.mm_02_40_
        flag = true;
    else
        flag = false;
    end
end