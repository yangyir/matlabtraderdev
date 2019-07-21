classdef cTDSQRM < cTradeRiskManager
% class of trade level risk manager with TDSQ
    properties
    end
    
    properties
        bucket_count_@double = 0
    end
    
    methods
        function obj = cTDSQRM
            obj.name_ = 'tdsqrm';
        end
    end
    
    methods
        [unwindtrade] = riskmanagement(obj,varargin)
    end
end