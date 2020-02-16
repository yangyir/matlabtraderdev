classdef cSpiderman < cTradeRiskManager
    properties
        type_@char
        hh0_@double
        ll0_@double
        hh1_@double
        ll1_@double
        pxstoploss2_@double = -9.99                                         %stoploss at candle level
    end
    
    properties (Access = private)
        bucket_count_@double = 0
    end
       
    methods
        function obj = cSpiderman
            obj.name_ = 'spiderman';
        end
    end
    
    methods
        [unwindtrade] = riskmanagement(obj,varargin)
        [unwindtrade] = riskmanagementwithcandle(obj,candlek,varargin)
        [] = updatestoploss(obj,varargin)
    end
    
end

