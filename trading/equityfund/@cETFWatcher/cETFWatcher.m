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
       
    properties (SetAccess = private, GetAccess = private)
        conn_@cWind
        %
        codes_index_@cell
        codes_sector_@cell
        codes_stock_@cell
        names_index_@cell
        names_sector_@cell
        names_stock_@cell
        %
        dailybar_shcomp_@double
        %
        dailybarmat_index_@cell
        dailybarmat_sector_@cell
        dailybarmat_stock_@cell
        dailybarstruct_index_@cell
        dailybarstruct_sector_@cell
        dailybarstruct_stock_@cell
        %
        intradaybarmat_index_@cell
        intradaybarmat_sector_@cell
        intradaybarmat_stock_@cell
        intradaybarstruct_index_@cell
        intradaybarstruct_sector_@cell
        intradaybarstruct_stock_@cell
        
    end
    
    properties (GetAccess = public, SetAccess = private)
        timer_interval_@double = 60 %refresh the watcher every minute
    end
    
    methods
        %constructor
        function obj = cETFWatcher(varargin)
            obj = init(obj,varargin{:});
        end
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
        %
        [] = refresh(obj,varargin)
        [] = print(obj, varargin)
        %
        [] = showfigures(obj,varargin)
        [] = reload(obj,varargin)
        [] = savedata(obj,varargin)
        %
        [] = printsignal(obj,varargin)
        %
        [] = eodanalysis(obj,varargin)
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
        [] = printmarket(obj,varargin)
        [] = printtrade(obj,varargin)
    end
    
    
    
end
