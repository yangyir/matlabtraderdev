classdef cWRStep < cTradeRiskManager
    % WRStep (Williams Ratio Step) is used on trade level rather than
    % position level, on which is a consolidation of trades of which the
    % same instrument is traded.
    % 20190121 yangyiran
    properties
        criticalvalue1_@double
        criticalvalue2_@double
        stepvalue_@double = 10
        buffer_@double = 1
    end
    
    properties (GetAccess = public, SetAccess = private)
        breachmidline_@double = 0
        breachlimitline_@double = 0
    end
    
    properties (Access = private)
        bucket_count_@double = 0
    end
    
    methods
        function obj = cWRStep
            obj.name_ = 'wrstep';
        end
        
        function set.stepvalue_(obj,val)
            if ~(val == 10 || val == 20 || val == 25 || val == 50)
                error('cWRStep;invalid stepvalue:must be 10,20,25 or 50')
            end
            obj.stepvalue_ = val;
        end
    end
    
    methods
        [unwindtrade] = riskmanagement(obj,varargin)
        [unwindtrade] = riskmanagementwithcandle(obj,candlek,wr,varargin)
    end
end

