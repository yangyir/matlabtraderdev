function [ret] = istime2refresh(obj,varargin)
% a cETFWatcher's member function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.time;
    
    ret = false;
    obj.status_ = 'sleep';
    
    hh = hour(t);
    mm = minute(t);
    ss = second(t);
    
    if hh > 15 || hh < 9
        if mod(mm,10) == 0 && ss <= 1
            fprintf('%s %s sleeps......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'),obj.timer_.Name);
            ret = true;
        end
%         ret = true;
        return
    end
    
    obj.status_ = 'working';
    
    % when market closes at 15:00pm
    if hh == 15 && mm == 0 && ss < 1
        ret = true;
        return
    end
    
    %when market just to open at 09:00am
    if hh == 8 && mm == 59 && ss >= 59
        ret = true;
        return
    end
        
    minutespassed = 60*hh+mm;
    
    %when market refreshes every 10 mins
    if hh >= 9 && hh <= 14 && mod(mm,10) == 0 && ss <= 1
        if minutespassed > 690 && minutespassed < 780
            fprintf('%s %s sleeps......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'),obj.timer_.Name);
            return
        end
        ret = true;
        return
    end
end