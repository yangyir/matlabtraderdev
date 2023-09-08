function [] = start(monitorbase)
%cMonitorBase
    monitorbase.status_ = 'working';
    monitorbase.settimer;
    start(monitorbase.timer_);
end
%end of start