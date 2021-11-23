function stop(obj)
%cETFWatcher
    obj.status_ = 'sleep';
    try
        stop(obj.timer_);
    catch e
        fprintf('%s\n',e.message);
    end
end