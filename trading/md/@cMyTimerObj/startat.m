function [] = startat(timerobj,dtstr)
    timerobj.status_ = 'working';
    timerobj.settimer;
    y = year(dtstr);
    m = month(dtstr);
    d = day(dtstr);
    hh = hour(dtstr);
    mm = minute(dtstr);
    ss = second(dtstr);
    startat(timerobj.timer_,y,m,d,hh,mm,ss);
end
%end of startat