function dtnumarray = gendatetime(dtstart,dtend,freq)
if isnumeric(dtstart)
    startdtnum = dtstart;
elseif ischar(dtstart)
    startdtnum = datenum(dtstart);
end

if isnumeric(dtend)
    enddtnum = dtend;
elseif ischar(dtend)
    enddtnum = datenum(dtend);
end

interval = freq.num;

dtnum = startdtnum;
% fprintf('%s\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
y = year(dtnum);
m = month(dtnum);
d = day(dtnum);
hh = hour(dtnum);
mm = minute(dtnum);
ss = second(dtnum);

leapyear = mod(y,4) == 0;

dtnumarray = zeros(10000,1);
count = 1;
dtnumarray(count) = dtnum;

while dtnum < enddtnum
    if strcmpi(freq.str,'s')
        ss = ss + interval;
        if ss >= 60
            mm = mm+1;
            ss = ss-60;
        end
        if mm >= 60
            hh = hh+1;
            mm = mm-60;
        end
        
        if hh >= 24
            d = d+1;
            hh = hh-24;
        end
        
        switch m
            case {1,3,5,7,8,10,12}
                if d > 31
                    m = m+1;
                    d = d-31;
                end
            case 2
                if leapyear
                    if d > 28
                        m = m+1;
                        d = d-28;
                    end
                else
                    if d > 29
                        m = m+1;
                        d = d-29;
                    end
                end
            case {4,6,9,11}
                if d > 30
                    m = m+1;
                    d = d-30;
                end
            otherwise
        end
        
        if m > 12
            y=y+1;
            m=m-12;
        end
        
        ystr = num2str(y);
        if m < 10, mstr = ['0',num2str(m)]; else mstr = num2str(m); end
        if d < 10, dstr = ['0',num2str(d)]; else dstr = num2str(d); end
        if hh < 10, hhstr = ['0',num2str(hh)]; else hhstr = num2str(hh); end
        if mm < 10, mmstr = ['0',num2str(mm)]; else mmstr = num2str(mm); end
        if ss < 10, ssstr = ['0',num2str(ss)]; else ssstr = num2str(ss); end
        dtstr = [ystr,'-',mstr,'-',dstr,' ',hhstr,':',mmstr,':',ssstr];
        dtnum = datenum(dtstr);
        
    elseif strcmpi(freq.str,'m')
        mm = mm + interval;
        if mm >= 60
            hh = hh+1;
            mm = mm-60;
        end
        
        if hh >= 24
            d = d+1;
            hh = hh-24;
        end
        
        switch m
            case {1,3,5,7,8,10,12}
                if d > 31
                    m = m+1;
                    d = d-31;
                end
            case 2
                if leapyear
                    if d > 28
                        m = m+1;
                        d = d-28;
                    end
                else
                    if d > 29
                        m = m+1;
                        d = d-29;
                    end
                end
            case {4,6,9,11}
                if d > 30
                    m = m+1;
                    d = d-30;
                end
            otherwise
        end
        
        if m > 12
            y=y+1;
            m=m-12;
        end
        
        ystr = num2str(y);
        if m < 10, mstr = ['0',num2str(m)]; else mstr = num2str(m); end
        if d < 10, dstr = ['0',num2str(d)]; else dstr = num2str(d); end
        if hh < 10, hhstr = ['0',num2str(hh)]; else hhstr = num2str(hh); end
        if mm < 10, mmstr = ['0',num2str(mm)]; else mmstr = num2str(mm); end
        if ss < 10, ssstr = ['0',num2str(ss)]; else ssstr = num2str(ss); end
        dtstr = [ystr,'-',mstr,'-',dstr,' ',hhstr,':',mmstr,':',ssstr];
        dtnum = datenum(dtstr);
        
    elseif strcmpi(freq.str,'h')
        dtnum = dtnum + interval/24;
        y = year(dtnum);
        m = month(dtnum);
        d = day(dtnum);
        hh = hour(dtnum);
        mm = minute(dtnum);
        ss = second(dtnum);
        ystr = num2str(y);
        if m < 10, mstr = ['0',num2str(m)]; else mstr = num2str(m); end
        if d < 10, dstr = ['0',num2str(d)]; else dstr = num2str(d); end
        if hh < 10, hhstr = ['0',num2str(hh)]; else hhstr = num2str(hh); end
        if mm < 10, mmstr = ['0',num2str(mm)]; else mmstr = num2str(mm); end
        if ss < 10, ssstr = ['0',num2str(ss)]; else ssstr = num2str(ss); end
        
        dtstr = [ystr,'-',mstr,'-',dstr,' ',hhstr,':',mmstr,':',ssstr];
        dtnum = datenum(dtstr);
        
    elseif strcmpi(freq.str,'d')
        dtnum = dtnum + interval;    
    else
        error('invalid frequency')
    end
%     fprintf('%s\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
    count = count + 1;
    dtnumarray(count) = dtnum;
end

dtnumarray = dtnumarray(1:count,:);




end

