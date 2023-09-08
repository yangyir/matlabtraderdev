function [] = settimerinterval(obj,monitorbase)
%cMonitorBase
    obj.timer_interval_ = monitorbase;
    if ~isempty(obj.timer_) && isa(obj.timer_,'timer') && ...
            ~isempty(timerfind('Tag',[class(obj),'-timer']))
        obj.timer_.Period = monitorbase;
        obj.timer_.StartDelay = min(monitorbase,5);
    end
end