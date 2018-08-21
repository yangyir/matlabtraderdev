function [flag] = istime2loadmktdata(obj,t)
%note:yangyiran 20180821
%the market (historical) data is loaded between 08:50am and 09:00am on 
%every trading day
    
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
    
    if mm >= obj.mm_08_50_ && mm < obj.mm_09_00_
        flag = true;
    else
        flag = false;
    end
    
end