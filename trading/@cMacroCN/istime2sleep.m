function [flag] = istime2sleep(macrocn,t)
%cMacroCN    
    flag = 1;
    macrocn.status_ = 'sleep';
    
    hh = hour(t);
    mm = minute(t);
    ss = second(t);
    
    HH_MARKETOPEN = 9;
    HH_MARKETCLOSE = 17;
    MM_INTERVAL2PRINT = 10;
    
    if (hh > HH_MARKETCLOSE || hh < HH_MARKETOPEN) || (hh == HH_MARKETCLOSE && mm > 0)
        %market closes
        if mod(mm,MM_INTERVAL2PRINT) == 0 && ss <= 1
            fprintf('%s %s sleeps......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'),macrocn.timer_.Name);
        end
        return
    end
    
    minutespassed = 60*hh+mm;
    if minutespassed > 690 && minutespassed < 780 
        %market breaks between 11:30am and 13:00pm
        if mod(mm,MM_INTERVAL2PRINT) == 0 && ss <= 1
            fprintf('%s %s sleeps......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'),macrocn.timer_.Name);
        end
        return
    end
    
    
    flag = 0;
    macrocn.status_ = 'working';

end

