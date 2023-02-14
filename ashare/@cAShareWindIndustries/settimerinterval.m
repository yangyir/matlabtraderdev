function [] = settimerinterval(obj,timerinterval)
%cAshareWindIndustries
    obj.timer_interval_ = timerinterval;
    if ~isempty(obj.timer_) && isa(obj.timer_,'timer') && ...
            ~isempty(timerfind('Tag',[class(obj),'-timer']))
        obj.timer_.Period = timerinterval;
        obj.timer_.StartDelay = min(timerinterval,5);
    end
end