function stop(mytimerobj)
    mytimerobj.status_ = 'sleep';
    try
        stop(mytimerobj.timer_);
        %delete the timer object from memory
        delete(mytimerobj.timer_);
    catch
    end
end
%end of stop