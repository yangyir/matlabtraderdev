function [] = stop(strategy)
if isempty(strategy.timer_)
    return
else
    stop(strategy.timer_);
end
end

