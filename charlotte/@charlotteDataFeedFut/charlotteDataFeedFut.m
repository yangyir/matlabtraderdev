classdef charlotteDataFeedFut < handle
    events
        NewDataArrived
        ErrorOccurred
        MarketOpen
        MarketClose
    end
    
    properties
        codes_@cell
        running_@logical = false
        status_@char = 'sleep';
        updateinterval_@double = 0.5    %default interval of 0.5 seconds
    end
    
    properties (Access = private)
        timer_
        qms_
        qmsconnected_@logical = false
        lastticktime_@double
    end
    
    properties (GetAccess = private, SetAccess = private)
        mm_02_30_@double = 150   % all futures listed in china stop trading
        mm_02_40_@double = 160   % timer sleeps during the night
        mm_08_50_@double = 530   % timer wakes up in the morning
        mm_09_00_@double = 540   % commodity futures start trading a.m 
        mm_09_30_@double = 570   % financial futures start trading a.m
        mm_11_30_@double = 690   % all futures stop trading a.m
        mm_11_31_@double = 691   % timer sleeps during the lunch break
        mm_12_59_@double = 779   % timer wakes up after the lunch break
        mm_13_00_@double = 780   % financial futures start trading p.m
        mm_13_30_@double = 810   % commodity futures start trading p.m
        mm_15_00_@double = 900   % commodity and eqindex futures stop trading p.m
        mm_15_15_@double = 915   % govtbond futures stop trading p.m
        mm_15_25_@double = 925   % timer sleeps again and wait for the evening session if there is any
        mm_20_50_@double = 1250  % timer wakes up again for evening trading 
        mm_21_00_@double = 1260  % derivatives start trading evening 
    end
    
    methods
        function obj = charlotteDataFeedFut(varargin)
            obj = init(obj,varargin{:});
        end
        %
        function set.updateinterval_(obj, interval)
            if interval > 0
                obj.updateinterval_ = interval;
                obj.stop();
                obj.start();
            else
                notify(obj, 'ErrorOccurred', ...
                    charlotteErrorEventData('Interval must be positive'));
            end
        end
    end
    
    methods
        [] = start(obj)
        [] = stop(obj)
        [] = delete(obj)
        lastT = getLastTickTime(obj,code)
        [] = onMarketOpen(obj,~,eventData)
        [] = onMarketClose(obj,~,eventData) 
    end
    
    methods (Access = private)
        obj = init(obj,varargin)
        [] = generateNewData(obj)
        [flag] = istime2sleep(obj,t)
    end
end