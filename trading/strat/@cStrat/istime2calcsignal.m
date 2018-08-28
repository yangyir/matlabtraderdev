function [flag] = istime2calcsignal(obj,t)
    calcsignaltimeinterval = obj.calcsignal_interval_;
    
    secondsperday = 86400;
    secondsbuckets = 0:calcsignaltimeinterval:secondsperday;
    
    thissecond = 3600*hour(t)+60*minute(t)+second(t);
    if thissecond == 0
        flag = false;
        return
    end
    
    idx = secondsbuckets(1:end-1) < thissecond & secondsbuckets(2:end) >= thissecond;
    
    thiscount = find(secondsbuckets == secondsbuckets(idx));
    
    if thiscount == obj.getcalcsignalbucket
        flag = false;
    else
        flag = true;
        obj.setcalcsignalbucket(thiscount);
        if obj.printflag_
            fprintf('calculate signal at:%s...\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
        end
    end

end