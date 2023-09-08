classdef cMonitorBase < handle
    %CMONITORBASE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name_@char
        mode_@char = 'realtime'
        status_@char = 'working'
        onerror_@char = 'stop'
        
        timer_
    end
    
    properties (GetAccess = public, SetAccess = private)
        timer_interval_@double = 60 %refresh the monitor every minute
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
        function [] = set.mode_(obj,modein)
            if ~(strcmpi(modein,'realtime') || strcmpi(modein,'replay') || strcmpi(modein,'demo'))
                error('cMonitorBase:mode_ property can be realtime or replay only')
            end
            obj.mode_ = modein;
        end
        %
        function [] = set.status_(obj,statusin)
            if ~(strcmpi(statusin,'sleep') || strcmpi(statusin,'working'))
                error('cMonitorBase:status_ property can be sleep or working only')
            end
            obj.status_ = statusin;
        end
        %
        function [] = set.onerror_(obj,onerrstr)
            if ~(strcmpi(onerrstr,'resume') || strcmpi(onerrstr,'stop'))
                error('cMonitorBase:onerror_ property can be resume or stop only')
            end
            obj.onerror_ = onerrstr;
        end
        %
    end
    
    methods (Abstract)
        [] = refresh(obj,varargin)
        [] = print(obj,varargin)
        [] = savemktdata(obj,varargin)
        [] = loadmktdata(obj,varargin)
        [] = savetrades(obj,varargin)
        [] = loadtrades(obj,varargin)
        %
        [t] = getreplaytime(obj,varargin)
        %
        [flag] = istime2sleep(obj,t)
        [flag] = istime2print(obj,t)
        [flag] = istime2savemktdata(obj,t)
        [flag] = istime2savetrades(obj,t)
        [flag] = istime2loadmktdata(obj,t)
        [flag] = istime2loadtrades(obj,t)
        %
    end
    
end

