classdef cMyTimerObj < handle
    properties
        name_@char = 'timer'
        mode_@char = 'realtime'
        status_@char = 'sleep'
        timer_@timer
        %refresh the mde every minute
        timer_interval_@double = 60
    end
    
    methods
        [] = start(obj)
        [] = startat(obj)
        [] = stop(obj)
        [] = settimer(obj)
        [] = replay_timer_fcn(obj,~,event)
        [] = start_timer_fcn(~,~,event)
        [] = stop_timer_fcn(~,~,event)
    end
    
    methods (Abstract)
        [] = refresh(obj)
    end
end