function [ ret ] = isable2trade( obj, t )
%cFutures
    if ischar(t), t = datenum(t);end
    
    wkday = weekday(t);
    %definitely not able to trade on Sundays
    if wkday == 1
        ret = false;
        return
    end
    
    hh = hour(t);
    %definitely not able to trade after 2:30 on Saturdays
    if wkday == 7 && hh >= 3
        ret = false;
        return
    end
        
    if hh >= 3
        tdatenum = floor(t);
    else
        tdatenum = floor(t-1);
    end
    
    tdatestr = datestr(tdatenum);
    n = size(obj.break_interval,1);
    ret = false;
    isnight = false;
    for i = 1:n
        tstart = datenum([tdatestr,' ',obj.break_interval{i,1}]);
        if strcmpi(obj.break_interval{i,2},'01:00:00') || strcmpi(obj.break_interval{i,2},'02:30:00')
            tend = datenum([datestr(tdatenum+1),' ',obj.break_interval{i,2}]);
        else
            tend = datenum([tdatestr,' ',obj.break_interval{i,2}]);
        end
        if t >= tstart && t <= tend
            ret = true;
            if strcmpi(obj.break_interval{i,1},'21:00:00'), isnight = true;end
            break
        end
    end
    
    %double check whether we have market open on that night
    %if the next day or the next monday is a public holiday, we don't have
    %market open during the night
    if ret && isnight
       if weekday(tdatenum) == 6
           nextmonday = tdatenum + 3;
           if isholiday(nextmonday), ret = false; end
       else
           nextdate = tdatenum + 1;
           if isholiday(nextdate), ret = false;end
       end
    end

end

