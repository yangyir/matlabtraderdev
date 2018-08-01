classdef cMyTimerObj < handle
    properties
        name_@char = 'timer'
        mode_@char = 'realtime'
        status_@char = 'sleep'
        timer_@timer
        timer_interval_@double = 60  %refresh the mde every minute
        
    end
    
    methods
        function [] = set.mode_(obj,modein)
            if ~(strcmpi(modein,'realtime') || strcmpi(modein,'replay'))
                error('mode of timer object can be realtime or replay only')
            end
            obj.mode_ = modein;
        end
        
        function [] = set.status_(obj,statusin)
            if ~(strcmpi(statusin,'sleep') || strcmpi(statusin,'working'))
                error('status of timer object can be sleep or working only')
            end
            obj.status_ = statusin;
        end
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