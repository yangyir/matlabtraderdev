function [] = start(timerobj)
    timerobj.status_ = 'working';
    timerobj.settimer;
    start(timerobj.timer_);
end
%end of start