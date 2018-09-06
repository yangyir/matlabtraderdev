function stop(mytimerobj)
    mytimerobj.status_ = 'sleep';
    try
        stop(mytimerobj.timer_);
        %delete the timer object from memory
%         delete(mytimerobj.timer_);
    catch e
        fprintf('%s\n',e.message);
    end
end
%end of stop