function [flag] = istime2loadtrades(obj,t)
%note:yangyiran 20180821
%the trade array is loaded between 1) 08:50am and 09:00am or 2) 
%20:50pm and 21:00pm on each trading day
    
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
    
    if (mm > obj.mm_08_50_+1 && mm < obj.mm_09_00_) || ...
            (mm > obj.mm_20_50_+1 && mm < obj.mm_21_00_)
        flag = true;
    else
        flag = false;
    end
end