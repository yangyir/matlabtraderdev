classdef cETFWatcher < handle
    % CETFWATCHER 
    % watcher of ETF's market price and technical indicators 
    
    properties
        name_@char = 'etfwatcher'
        mode_@char = 'realtime'
        status_@char = 'sleep'
        onerror_@char = 'stop'
        %
        timer_
    end
    
    properties (GetAccess = public, SetAccess = private)
        timer_interval_@double = 60 %refresh the watcher every minute
    end
    
    methods
        function [] = set.mode_(obj,modein)
            if ~(strcmpi(modein,'realtime') || strcmpi(modein,'replay') || strcmpi(modein,'demo'))
                error('cETFWatcher:mode property can be realtime or replay only')
            end
            obj.mode_ = modein;
        end
        %
        function [] = set.status_(obj,statusin)
            if ~(strcmpi(statusin,'sleep') || strcmpi(statusin,'working'))
                error('status of timer object can be sleep or working only')
            end
            obj.status_ = statusin;
        end
        %
        function [] = set.onerror_(obj,onerrstr)
            if ~(strcmpi(onerrstr,'resume') || strcmpi(onerrstr,'stop'))
                error('on error of timer object can be resume or stop only')
            end
            obj.onerror_ = onerrstr;
        end
        %
    end
    
    methods
        [] = start(obj)
        [] = stop(obj)
        [] = settimer(obj)
        [] = replay_timer_fcn(obj,~,event)
        [] = start_timer_fcn(~,~,event)
        [] = stop_timer_fcn(~,~,event)
        %
        [] = settimerinterval(obj,timerinterval)
    end
    
    methods
        [] = refresh(obj,varargin)
    end
    
end

