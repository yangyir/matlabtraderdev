function stop(mytimerobj)
    mytimerobj.status_ = 'sleep';
    stop(mytimerobj.timer_);
end
%end of stop