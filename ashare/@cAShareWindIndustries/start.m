function [] = start(timerobj)
%cAShareWindIndustries
    timerobj.status_ = 'working';
    timerobj.settimer;
    start(timerobj.timer_);
end
%end of start