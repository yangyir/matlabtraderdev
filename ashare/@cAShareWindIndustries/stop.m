function stop(obj)
%cAShareWindIndustries
    obj.status_ = 'sleep';
    try
        stop(obj.timer_);
    catch e
        fprintf('%s\n',e.message);
    end
end