classdef cMyTimerObj < handle
    properties
        name_@char = 'timer'
        mode_@char = 'realtime'
        status_@char = 'sleep'
        timer_@timer
        timer_interval_@double = 60  %refresh the mde every minute
        
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