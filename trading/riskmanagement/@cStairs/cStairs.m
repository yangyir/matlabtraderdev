classdef cStairs < cTradeRiskManager
    properties
        reserveratio_@double = 0.25;
        dynamicstoploss_@double
        maxpnl_@double = 0;
    end
    
    methods
        function obj = cStairs
            obj.name_ = 'stairs';
        end
    end
    
    properties (Access = private)
        bucket_count_@double = 0
    end
    
    methods
        [unwindtrade] = riskmanagement(obj,varargin)
        [unwindtrade] = riskmanagementwithcandle(obj,candlek,varargin)
    end
end