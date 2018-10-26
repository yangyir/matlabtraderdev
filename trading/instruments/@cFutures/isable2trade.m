function [ ret ] = isable2trade( obj, t )
%cFutures
    if ischar(t)
        t = datenum(t);
    end
    
    
    
    
    wkday = weekday(t);
    if wkday == 1
        ret = false;
        return
    end
    
    hh = hour(t);
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
    for i = 1:n
        tstart = datenum([tdatestr,' ',obj.break_interval{i,1}]);
        if strcmpi(obj.break_interval{i,2},'01:00:00') || strcmpi(obj.break_interval{i,2},'02:30:00')
            tend = datenum([datestr(tdatenum+1),' ',obj.break_interval{i,2}]);
        else
            tend = datenum([tdatestr,' ',obj.break_interval{i,2}]);
        end
        if t >= tstart && t <= tend
            ret = true;
            break
        end
    end

end

