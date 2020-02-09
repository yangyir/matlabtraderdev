classdef cSpiderman < cTradeRiskManager
    properties
        pxstoploss2_@double = -9.99                                         %stoploss at candle level
    end
       
    methods
        function obj = cSpiderman
            obj.name_ = 'spiderman';
        end
    end
    
    methods
        [unwindtrade] = riskmanagement(obj,varargin)
        [ret] = updatestoploss(obj,varargin)
    end
    
end

