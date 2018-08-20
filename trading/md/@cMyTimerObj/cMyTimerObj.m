classdef cMyTimerObj < handle
    properties
        name_@char = 'timer'
        mode_@char = 'realtime'
        status_@char = 'sleep'
        timer_@timer
        timer_interval_@double = 60  %refresh the mde every minute
        %
        printflag_@logical = true
        print_timeinterval_@double = 60   %display the relative information every minute
        %
        fileioflag_@logical = true        %save/load data from file
    end
    
    properties (Access = private)
        print_bucket_@double = 0
        flag_saved_@logical = false
        flag_loaded_@logical = false
    end
      
    properties (GetAccess = public, SetAccess = private)
        mm_02_30_@double = 150   % all derivatives stop trading
        mm_02_40_@double = 160   % timer sleeps during the night
        mm_08_50_@double = 530   % timer wakes up in the morning
        mm_09_00_@double = 540   % derivatives start trading a.m 
        mm_11_30_@double = 690   % derivatives stop trading a.m 
        mm_13_00_@double = 780   % derivatives start trading p.m    
        mm_15_15_@double = 915   % derivatives stop trading p.m
        mm_15_25_@double = 925   % timer sleeps again and wait for the evening session if there is any
        mm_20_50_@double = 1250  % timer wakes up again for evening trading 
        mm_21_00_@double = 1260  % derivatives start trading evening 
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
        [flag] = issleep(obj,t)
        
        function printbucket = getprintbucket(obj)
            printbucket = obj.print_bucket_;
        end
        
        function [] = setprintbucket(obj,val)
            obj.print_bucket_ = val;
        end
        
        function flag = getflagsaved(obj)
            flag = obj.flag_saved_;
        end
        
        function [] = setflagsaved(obj,val)
            obj.flag_saved_ = val;
        end
        
        function flag = getflagloaded(obj)
            flag = obj.flag_loaded_;
        end
        
        function [] = setflagloaded(obj,val)
            obj.flag_loaded_ = val;
        end
        
    end
    
    methods (Abstract)
        [] = refresh(obj,varargin)
        [] = print(obj,varargin)
        [] = savetofile(obj,varargin)
        [] = loadfromfile(obj,varargin)
    end
end