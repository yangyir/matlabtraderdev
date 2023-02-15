classdef cAShareWindIndustries < handle
    % class definition:
    % wind industries for A share
    properties
        name_@char = 'asharewindindustries'
        mode_@char = 'realtime'
        status_@char = 'sleep'
        onerror_@char = 'stop'
        %
        timer_
    end
    %
    properties (SetAccess = private, GetAccess = private)
        conn_@cWind
        %
        codes_index_@cell
        names_index_@cell
        %
        dailybarmat_index_@cell
        dailybarstruct_index_@cell
        dailybarriers_conditional_index_@double
        %
        pos_index_@cell
        %
        dailystatus_index_@double                                        %-2:conditional bearish;-1:bearish;0:neutral;1:bullish;2:conditional bullish
                   
    end
    %
    properties (GetAccess = public, SetAccess = private)
        timer_interval_@double = 60 %refresh the watcher every minute
    end
    %
    methods
        %constructor
        function obj = cAShareWindIndustries(varargin)
            obj = init(obj,varargin{:});
        end
    end
    %
    methods
        function [] = set.mode_(obj,modein)
            if ~(strcmpi(modein,'realtime') || strcmpi(modein,'replay') || strcmpi(modein,'demo'))
                error('cAShareWindIndustries:mode property can be realtime or replay only')
            end
            obj.mode_ = modein;
        end
        %
        function [] = set.status_(obj,statusin)
            if ~(strcmpi(statusin,'sleep') || strcmpi(statusin,'working'))
                error('cAShareWindIndustries:status of timer object can be sleep or working only')
            end
            obj.status_ = statusin;
        end
        %
        function [] = set.onerror_(obj,onerrstr)
            if ~(strcmpi(onerrstr,'resume') || strcmpi(onerrstr,'stop'))
                error('cAShareWindIndustries:on error of timer object can be resume or stop only')
            end
            obj.onerror_ = onerrstr;
        end
        %
    end
    %
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
        [dailystruct] = showfigures(obj,varargin)
        [] = reload(obj,varargin)
        [] = savedata(obj,varargin)
        %
        [] = printsignal(obj,varargin)
        %
        [] = eodanalysis(obj,varargin)
        %
        [] = setposition(obj,varargin)
        [res] = getposition(obj,varargin)
        %
        [ret] = riskmanagement(obj,varargin)
        %
        [ret] = getvariables(obj,varargin)
    end
    %
     methods (Access = private)
        obj = init(obj,varargin)
        [] = printmarket(obj,varargin)
        [] = printtrade(obj,varargin)
        [ret] = istime2refresh(obj,varargin)
     end
end

