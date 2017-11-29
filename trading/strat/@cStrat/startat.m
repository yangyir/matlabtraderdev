function [] = startat(strategy,dtstr)
    strategy.settimer;
    y = year(dtstr);
    m = month(dtstr);
    d = day(dtstr);
    hh = hour(dtstr);
    mm = minute(dtstr);
    ss = second(dtstr);
    startat(strategy.timer_,y,m,d,hh,mm,ss);
end


