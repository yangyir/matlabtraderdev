function [flag] = istime2print(obj,t)
    printtimeinterval = obj.print_timeinterval_;
    
    secondsperday = 86400;
    secondsbuckets = 0:printtimeinterval:secondsperday;
    
    thissecond = 3600*hour(t)+60*minute(t)+second(t);
    if thissecond == 0
        flag = false;
        return
    end
    
    idx = secondsbuckets(1:end-1) < thissecond & secondsbuckets(2:end) >= thissecond;
    
    thiscount = find(secondsbuckets == secondsbuckets(idx));
    
    if thiscount == obj.getprintbucket
        flag = false;
    else
        flag = true;
        obj.setprintbucket(thiscount);
    end
    
    if (thissecond > 53999 && thissecond <= 54000) || ...
            (thissecond > 54899 && thissecond <= 54900)
        flag = true;
    end

end