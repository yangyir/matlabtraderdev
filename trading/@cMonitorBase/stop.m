function stop(monitorbase)
    monitorbase.status_ = 'sleep';
    try
        stop(monitorbase.timer_);
    catch e
        fprintf('%s\n',e.message);
    end
end
%end of stop