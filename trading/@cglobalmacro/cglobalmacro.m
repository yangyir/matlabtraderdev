classdef cglobalmacro < handle
    % monitor of global marco variables
    properties
        name_@char = 'globalmacro'
        %
        timer_
    end
    
    properties (SetAccess = private, GetAccess = private)
        conn_@cWind
        %
        codes_rates_@cell
        codes_fx_@cell
        codes_eqindex_@cell
        codes_comdty_@cell
        %
        dailybarstruct_rates_@cell
        dailybarstruct_fx_@cell
        dailybarstruct_eqindex_@cell
        dailybarstruct_comdty_@cell
        %
        dailybarriers_conditional_rates_@double
        dailybarriers_conditional_fx_@double
        dailybarriers_conditional_eqindex_@double
        dailybarriers_conditional_comdty_@double
        %
        dailystatus_rates_@double
        dailystatus_fx_@double
        dailystatus_eqindex_@double
        dailystatus_comdty_@double
        
    end
    
    properties (GetAccess = public, SetAccess = private)
        timer_interval_@double = 60 %refresh the watcher every minute
    end
    
    methods
        %constructor
        function obj = cglobalmacro(varargin)
            obj = init(obj,varargin{:});
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
        [] = settimerinterval(obj,timerinterval)
        %
        [] = refresh(obj,varargin)
        [] = print(obj, varargin)
        [res] = showfigures(obj,varargin)
        [] = reload(obj,varargin)
        
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
        
    end
end

