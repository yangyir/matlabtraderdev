function [ret] = istime2refresh(obj,varargin)
% a cETFWatcher's member function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.time;
    
    ret = 0;
    obj.status_ = 'sleep';
    
    hh = hour(t);
    mm = minute(t);
    ss = second(t);
    
    %hard-coded variables here
    HH_MARKETOPEN = 9;
    HH_MARKETCLOSE = 15;
    MM_INTERVAL2PRINT = 10;
    MM_INTERVAL2CHECKBARRIER = 1;
    
    
    if (hh > HH_MARKETCLOSE || hh < HH_MARKETOPEN) || (hh == HH_MARKETCLOSE && mm > 0)
        %market closes
        if mod(mm,MM_INTERVAL2PRINT) == 0 && ss <= 1
            fprintf('%s %s sleeps......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'),obj.timer_.Name);
            ret = 1;
        end
        return
    end
       
    minutespassed = 60*hh+mm;
    if minutespassed > 690 && minutespassed < 780 
        %market breaks between 11:30am and 13:00pm
        if mod(mm,MM_INTERVAL2PRINT) == 0 && ss <= 1
            fprintf('%s %s sleeps......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'),obj.timer_.Name);
                return
        end
    end
    
    obj.status_ = 'working';

    %when market just to open at 09:00am
    if hh == HH_MARKETOPEN-1 && mm == 59 && ss >= 59
        ret = 1;
        return
    end
    
    %when market open, refreshes every MM_INTERVAL2PRINT
    if hh >= HH_MARKETOPEN && hh <= HH_MARKETCLOSE-1 && mod(mm,MM_INTERVAL2PRINT) == 0 && ss <= 1        
        ret = 1;
        return
    end
    
    %when market open, check whether conditional barriers, i.e fractal hh
    %or ll has been breached or not
    if hh >= HH_MARKETOPEN && hh <= HH_MARKETCLOSE-1 && mod(mm,MM_INTERVAL2CHECKBARRIER) == 0 && ss <= 1
        ret = 2;
        return
    end
    
    % when market closes at 15:00pm
    if hh == HH_MARKETCLOSE && mm == 0 && ss < 1
        ret = 1;
        return
    end
end