function stop(obj)
%a charlotteDataFeedFX function
    if obj.running_
        stop(obj.timer_);
        delete(obj.timer_);
        obj.running_ = false;
    end
end