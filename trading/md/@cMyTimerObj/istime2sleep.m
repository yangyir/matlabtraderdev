function [flag] = istime2sleep(obj,t)
    if isnumeric(t)
        tnum = t;
    else
        tnum = datenum(t);
    end
    
    dnum = floor(tnum);
    
    %market definitely closes on public holidays
    if isholiday(dnum) && weekday(dnum) ~= 7
       obj.status_ = 'sleep';
       flag = true;
       return
    end
    
    %market definitely closes on Sundays
    if weekday(tnum) == 1
       obj.status_ = 'sleep';
       flag = true;
       return
    end
    
    hh = hour(tnum);
    mm = minute(tnum) + hh*60;
      
   %special treatment on Saturdays
   %market still open between 0:00am and 02:30am on Saturday unless
   %the next Monday is a public holiday
   if weekday(tnum) == 7    
       if mm >= obj.mm_02_40_
           obj.status_ = 'sleep';
           flag = true;
       else
           dnum = floor(tnum);
           nextMonday = dnum + 2;
           if isholiday(nextMonday)
               obj.status_ = 'sleep';
               flag = true;
           else
               obj.status_ = 'working';
               flag = false;
           end
       end
       return
   end
   
   %there is no evening market in case the next Monday is a public holiday
   if weekday(tnum) == 6
       nextMonday = dnum + 3;
       if isholiday(nextMonday) && mm >= obj.mm_15_25_
           obj.status_ = 'sleep';
           flag = true;
           return
       end
   end
   
   %market reopens on 9:00 am every week and mytimerobj restarts to work
   %from 8:50 am on Mondays
   if weekday(tnum) == 2 && mm < obj.mm_08_50_
       obj.status_ = 'sleep';
       flag = true;
       return
   end
   
   
   %weekday = 2,3,4,5,6
   %Monday,Tuesday,Wednesday,Thursday and Friday
   if (mm >= obj.mm_02_40_ && mm <  obj.mm_08_50_) || ...
           (mm > obj.mm_11_30_ && mm < obj.mm_13_00_) || ...
           (mm >= obj.mm_15_25_ && mm < obj.mm_20_50_)
       obj.status_ = 'sleep';
       flag = true;
   else
       obj.status_ = 'working';
       flag = false;
   end
       

end